# INFRASTRUCTURE SPECIFICATION & DESIGN

本ファイルは **Infrastructure Spec-Driven Development** の唯一の真実のソース (SSOT) です。

---

## 1. PHILOSOPHY

### 1.1 基本原則
- **本 INSTRUCTION が全ての真実** - コードよりも本仕様が優先
- **破壊的変更OK** - 既存コードが仕様と異なる場合は差し替える
- **最小構成** - 必要最小限のリソースから始める
- **粒度の完全一致** - AWS/GCP で構築単位を完全に揃える

### 1.2 開発フロー
1. INSTRUCTION で仕様を定義・更新
2. 仕様に基づいて Terraform コードを生成
3. レビュー後、適用 (**terraform apply は手動実行のみ**)
4. 変更があれば INSTRUCTION を更新し、1に戻る

---

## 2. DIRECTORY STRUCTURE

```
infra-spec-driven-multicloud/
├── INSTRUCTION.md                    # 本ファイル (SSOT)
├── README.md                         # プロジェクト概要
├── .gitignore
│
├── infra/                            # 呼び出し側 Terraform
│   ├── aws/
│   │   ├── vpc/
│   │   ├── subnet/
│   │   ├── route_table/
│   │   ├── nat_gateway/
│   │   ├── ecr/
│   │   ├── ecs/
│   │   ├── alb/
│   │   ├── cloudfront/
│   │   ├── rds/
│   │   ├── s3/
│   │   ├── lambda/
│   │   └── stepfunctions/
│   └── gcp/
│       ├── vpc/
│       ├── subnet/
│       ├── route/
│       ├── cloud_nat/
│       ├── artifact_registry/
│       ├── cloud_run/
│       ├── lb/
│       ├── cloud_cdn/
│       ├── cloud_sql/
│       ├── gcs/
│       ├── cloud_functions/
│       └── workflows/
│
├── modules/                          # 再利用可能な Terraform モジュール
│   ├── aws/                          # AWS モジュール (infra/aws と同じ粒度)
│   └── gcp/                          # GCP モジュール (infra/gcp と同じ粒度)
│
└── .github/
    └── workflows/                    # CI/CD パイプライン
        ├── aws-deploy.yml
        ├── gcp-deploy.yml
        └── multicloud-sync-check.yml
```

---

## 3. TERRAFORM GUIDELINES

### 3.1 ファイル構成

各リソースディレクトリは以下の構成とする:

```
resource_name/
├── main.tf          # リソース定義、provider設定、module呼び出し
├── variables.tf     # 入力変数定義
└── outputs.tf       # 出力値定義
```

### 3.2 命名規則

- **リソース名**: `{resource_type}.main` (例: `aws_vpc.main`)
- **変数名**: スネークケース (例: `vpc_cidr_block`)
- **モジュール名**: ディレクトリ名と一致 (例: `module "vpc"`)
- **タグ/ラベル**: 統一フォーマット
  ```hcl
  tags = {
    Name        = "resource-name"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "infra-spec-driven-multicloud"
  }
  ```

### 3.3 Module 設計

#### 粒度
- **1機能 = 1モジュール**
- AWS と GCP で対応するリソースは同じ粒度で作成
- 呼び出し側 (`infra/`) もモジュールと同じ粒度

#### 構造
```hcl
# modules/aws/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  # ...
}

# modules/aws/vpc/variables.tf
variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

# modules/aws/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### 3.4 共通化しない理由
- AWS と GCP は API が異なる
- 中身の完全共通化は保守性を下げる
- **名前・粒度・階層のみ完全一致させる**

### 3.5 Provider 設定

#### AWS
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### GCP
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
```

### 3.6 State 管理

- **ローカル state** から始める
- 本番環境では S3/GCS バックエンドに移行
- State lock は DynamoDB/GCS で実装

---

## 4. INFRASTRUCTURE DESIGN

### 4.1 ネットワーク構成

#### AWS VPC 設計

```
VPC: 10.0.0.0/16
├── Public Subnet (AZ-a):  10.0.1.0/24
├── Public Subnet (AZ-c):  10.0.2.0/24
├── Private Subnet (AZ-a): 10.0.11.0/24
└── Private Subnet (AZ-c): 10.0.12.0/24

Internet Gateway: 1個
NAT Gateway: 各AZに1個 (計2個)
Route Tables:
  - Public:  1個 (IGW向け)
  - Private: 2個 (各AZ用、NAT Gateway向け)
```

**詳細設定**:
- DNS Hostname: 有効
- DNS Support: 有効
- CIDR: 10.0.0.0/16
- Enable IPv6: 無効

**Subnet配置**:
| Subnet | AZ | CIDR | Type | Route |
|--------|----|----|------|-------|
| public-a | ap-northeast-1a | 10.0.1.0/24 | Public | IGW |
| public-c | ap-northeast-1c | 10.0.2.0/24 | Public | IGW |
| private-a | ap-northeast-1a | 10.0.11.0/24 | Private | NAT-a |
| private-c | ap-northeast-1c | 10.0.12.0/24 | Private | NAT-c |

**Route Table**:
- Public Route Table:
  - 0.0.0.0/0 → Internet Gateway
  - 10.0.0.0/16 → local
- Private Route Table (AZ-a):
  - 0.0.0.0/0 → NAT Gateway (AZ-a)
  - 10.0.0.0/16 → local
- Private Route Table (AZ-c):
  - 0.0.0.0/0 → NAT Gateway (AZ-c)
  - 10.0.0.0/16 → local

#### GCP VPC 設計

```
VPC: custom mode
├── Subnet (asia-northeast1): 10.1.1.0/24
└── Subnet (asia-northeast2): 10.1.2.0/24

Cloud NAT: 各リージョンに1個
Cloud Router: 各リージョンに1個
Routes: 自動生成 (default + custom)
```

**詳細設定**:
- Auto Create Subnetworks: 無効 (カスタムモード)
- Routing Mode: Regional
- MTU: 1460

**Subnet配置**:
| Subnet | Region | CIDR | Private Google Access |
|--------|--------|------|----------------------|
| subnet-asia-ne1 | asia-northeast1 | 10.1.1.0/24 | 有効 |
| subnet-asia-ne2 | asia-northeast2 | 10.1.2.0/24 | 有効 |

**Cloud NAT設定**:
- NAT IP allocation: 自動
- Minimum ports per VM: 64
- Enable endpoint independent mapping: 有効

### 4.2 コンテナレジストリ

#### AWS ECR

```
Repository: app-repo
├── Image Tag Mutability: MUTABLE
├── Scan on Push: 有効
├── Encryption: AES256
└── Lifecycle Policy: latest 10イメージ保持
```

**詳細設定**:
- Repository名: `{environment}-app-repo`
- Image scanning: 有効
- Tag immutability: MUTABLE (開発環境)
- Encryption type: AES256

#### GCP Artifact Registry

```
Repository: app-repo
├── Format: Docker
├── Location: asia-northeast1
└── Encryption: Google-managed
```

**詳細設定**:
- Repository名: `{environment}-app-repo`
- Format: Docker
- Mode: Standard
- Cleanup policy: latest 10イメージ保持

### 4.3 コンピューティング

#### AWS ECS

```
Cluster: app-cluster
├── Capacity Providers: FARGATE, FARGATE_SPOT
├── Container Insights: 有効
└── Service:
    ├── Launch Type: FARGATE
    ├── Task Definition:
    │   ├── CPU: 256 (.25 vCPU)
    │   ├── Memory: 512 MB
    │   └── Container: app
    ├── Desired Count: 2
    ├── Network: awsvpc
    │   ├── Subnets: private-a, private-c
    │   └── Security Group: ecs-sg
    └── Load Balancer: ALB
```

**Task Definition**:
```json
{
  "family": "app-task",
  "cpu": "256",
  "memory": "512",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "containerDefinitions": [{
    "name": "app",
    "image": "{account}.dkr.ecr.{region}.amazonaws.com/app-repo:latest",
    "portMappings": [{
      "containerPort": 8080,
      "protocol": "tcp"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/app",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
```

**Security Group (ECS)**:
- Inbound: 8080 from ALB Security Group
- Outbound: All traffic

#### GCP Cloud Run

```
Service: app-service
├── Region: asia-northeast1
├── CPU: 1
├── Memory: 512Mi
├── Min instances: 0
├── Max instances: 10
├── Concurrency: 80
├── Ingress: Internal and Cloud Load Balancing
└── Container:
    ├── Image: asia-northeast1-docker.pkg.dev/{project}/app-repo/app:latest
    └── Port: 8080
```

**詳細設定**:
- CPU allocation: CPU is allocated only during request processing
- Request timeout: 300s
- Execution environment: Second generation

### 4.4 ロードバランサー

#### AWS ALB

```
Application Load Balancer
├── Scheme: internet-facing
├── IP address type: ipv4
├── Subnets: public-a, public-c
├── Security Group: alb-sg
├── Listeners:
│   ├── HTTP:80 → Target Group (redirect to HTTPS)
│   └── HTTPS:443 → Target Group
├── Target Group:
│   ├── Type: ip
│   ├── Protocol: HTTP
│   ├── Port: 8080
│   ├── Health Check:
│   │   ├── Path: /health
│   │   ├── Interval: 30s
│   │   ├── Timeout: 5s
│   │   ├── Healthy threshold: 2
│   │   └── Unhealthy threshold: 3
│   └── Targets: ECS Tasks (auto-register)
└── Access Logs: S3 bucket
```

**Security Group (ALB)**:
- Inbound:
  - 80/tcp from 0.0.0.0/0
  - 443/tcp from 0.0.0.0/0
- Outbound: All traffic

#### GCP Load Balancer

```
External HTTP(S) Load Balancer
├── Backend Service:
│   ├── Backend: Cloud Run service
│   ├── Protocol: HTTP/2
│   ├── Session affinity: None
│   └── Health Check:
│       ├── Path: /health
│       ├── Port: 8080
│       ├── Check interval: 30s
│       └── Timeout: 5s
├── URL Map:
│   └── Default: Backend Service
└── Frontend:
    ├── Protocol: HTTPS
    ├── Port: 443
    └── Certificate: Google-managed
```

### 4.5 CDN

#### AWS CloudFront

```
Distribution
├── Origin: ALB DNS
├── Origin Protocol: HTTPS only
├── Viewer Protocol: Redirect HTTP to HTTPS
├── Cache Policy: CachingOptimized
├── Price Class: Use All Edge Locations
├── SSL Certificate: ACM
└── Logging: S3 bucket
```

**Cache Behavior**:
- Path pattern: Default (*)
- Allowed HTTP Methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
- Cache key: Include query strings and cookies
- TTL: Min=0, Max=31536000, Default=86400

#### GCP Cloud CDN

```
Cloud CDN (attached to Load Balancer)
├── Cache mode: CACHE_ALL_STATIC
├── Default TTL: 3600s
├── Max TTL: 86400s
├── Client TTL: 3600s
└── Negative caching: 有効
```

### 4.6 データベース

#### AWS RDS

```
RDS for PostgreSQL
├── Engine version: 15.x
├── Instance class: db.t3.micro
├── Storage:
│   ├── Type: gp3
│   ├── Size: 20 GB
│   └── Auto-scaling: 無効
├── Multi-AZ: 無効 (dev環境)
├── VPC: main-vpc
├── Subnets: private-a, private-c (DB Subnet Group)
├── Security Group: rds-sg
├── Backup:
│   ├── Retention: 7 days
│   └── Window: 03:00-04:00 UTC
└── Maintenance Window: Mon:04:00-Mon:05:00 UTC
```

**Security Group (RDS)**:
- Inbound: 5432/tcp from ECS Security Group
- Outbound: None

**Parameter Group**:
- rds.force_ssl: 1
- log_statement: ddl
- log_min_duration_statement: 1000

#### GCP Cloud SQL

```
Cloud SQL for PostgreSQL
├── Version: PostgreSQL 15
├── Machine type: db-f1-micro
├── Storage:
│   ├── Type: SSD
│   ├── Size: 10 GB
│   └── Auto-increase: 有効
├── High availability: 無効 (dev環境)
├── Region: asia-northeast1
├── Network: VPC
├── Private IP: 有効
├── Public IP: 無効
├── Backup:
│   ├── Automated: 有効
│   ├── Retention: 7 days
│   └── Window: 03:00-04:00 JST
└── Maintenance Window: Any
```

**Flags**:
- cloudsql.enable_pgaudit: on
- log_min_duration_statement: 1000

### 4.7 オブジェクトストレージ

#### AWS S3

```
Bucket: {environment}-app-bucket-{random}
├── Versioning: 有効
├── Encryption:
│   ├── Type: SSE-S3 (AES256)
│   └── Bucket Key: 有効
├── Block Public Access: 全て有効
├── Lifecycle Policy:
│   ├── Transition to IA: 30 days
│   ├── Transition to Glacier: 90 days
│   └── Expiration: 365 days
└── Access Logging: 有効 (to log bucket)
```

**Bucket Policy**:
- Deny all requests if not over HTTPS
- CloudFront OAI からのアクセスのみ許可

#### GCP GCS

```
Bucket: {environment}-app-bucket-{random}
├── Location: asia-northeast1
├── Storage class: Standard
├── Versioning: 有効
├── Encryption: Google-managed
├── Public access: Prevented
├── Lifecycle Policy:
│   ├── Move to Nearline: 30 days
│   ├── Move to Coldline: 90 days
│   └── Delete: 365 days
└── Access Logging: 有効
```

**IAM Binding**:
- Cloud CDN からのアクセスのみ許可

### 4.8 サーバーレス

#### AWS Lambda

```
Function: app-function
├── Runtime: python3.11 or nodejs20.x
├── Memory: 256 MB
├── Timeout: 30s
├── Environment Variables: from Parameter Store
├── VPC: main-vpc
│   ├── Subnets: private-a, private-c
│   └── Security Group: lambda-sg
├── Execution Role: lambda-execution-role
├── Reserved Concurrency: 10
└── Dead Letter Queue: SQS
```

**Security Group (Lambda)**:
- Outbound: 443/tcp to 0.0.0.0/0 (API calls)

**IAM Role**:
- AWSLambdaVPCAccessExecutionRole
- CloudWatch Logs write
- Parameter Store read

#### GCP Cloud Functions

```
Function: app-function
├── Runtime: python311 or nodejs20
├── Memory: 256 MB
├── Timeout: 30s
├── Environment Variables: from Secret Manager
├── VPC Connector: vpc-connector (to VPC)
├── Service Account: function-sa
├── Max instances: 10
└── Ingress: Internal and Cloud Load Balancing
```

**Service Account Permissions**:
- Cloud SQL Client
- Secret Manager Secret Accessor
- Cloud Logging Writer

### 4.9 ワークフロー

#### AWS Step Functions

```
State Machine: app-workflow
├── Type: STANDARD
├── Execution Role: stepfunctions-execution-role
├── Logging: CloudWatch Logs
└── Definition:
    ├── Task 1: Invoke Lambda (validate)
    ├── Task 2: Invoke Lambda (process)
    ├── Task 3: Invoke Lambda (notify)
    └── Error Handling: Catch & Retry
```

**IAM Role**:
- Lambda invoke
- CloudWatch Logs write

#### GCP Workflows

```
Workflow: app-workflow
├── Region: asia-northeast1
├── Service Account: workflow-sa
├── Logging: Cloud Logging
└── Definition:
    ├── Step 1: Call Cloud Function (validate)
    ├── Step 2: Call Cloud Function (process)
    ├── Step 3: Call Cloud Function (notify)
    └── Error Handling: try/except
```

**Service Account Permissions**:
- Cloud Functions Invoker
- Cloud Logging Writer

---

## 5. IAM & SERVICE ACCOUNT DESIGN

### 5.1 AWS IAM 設計

#### ECS Task Execution Role
```
Role: ecs-task-execution-role
Policies:
  - AmazonECSTaskExecutionRolePolicy (AWS Managed)
  - Custom:
    - ECR: GetAuthorizationToken, BatchCheckLayerAvailability, GetDownloadUrlForLayer, BatchGetImage
    - CloudWatch Logs: CreateLogStream, PutLogEvents
    - SSM Parameter Store: GetParameters (for secrets)
```

#### ECS Task Role
```
Role: ecs-task-role
Policies:
  - Custom:
    - S3: GetObject, PutObject (specific bucket)
    - RDS: rds-db:connect (specific DB)
    - SQS: SendMessage, ReceiveMessage (specific queue)
```

#### Lambda Execution Role
```
Role: lambda-execution-role
Policies:
  - AWSLambdaVPCAccessExecutionRole (AWS Managed)
  - Custom:
    - CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents
    - SSM Parameter Store: GetParameter, GetParameters
    - Secrets Manager: GetSecretValue (specific secret)
```

#### Step Functions Execution Role
```
Role: stepfunctions-execution-role
Policies:
  - Custom:
    - Lambda: InvokeFunction (specific functions)
    - CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents
```

### 5.2 GCP Service Account 設計

#### Cloud Run Service Account
```
Service Account: cloud-run-sa@{project}.iam.gserviceaccount.com
Roles:
  - Cloud SQL Client
  - Secret Manager Secret Accessor
  - Storage Object Viewer (specific bucket)
  - Cloud Logging Writer
```

#### Cloud Functions Service Account
```
Service Account: cloud-functions-sa@{project}.iam.gserviceaccount.com
Roles:
  - Cloud SQL Client
  - Secret Manager Secret Accessor
  - Cloud Logging Writer
  - Pub/Sub Publisher (specific topic)
```

#### Workflows Service Account
```
Service Account: workflows-sa@{project}.iam.gserviceaccount.com
Roles:
  - Cloud Functions Invoker (specific functions)
  - Cloud Logging Writer
```

### 5.3 最小権限の原則

- **リソース単位で権限付与** - `*` は使わない
- **期間制限** - 一時的な権限は TTL を設定
- **監査ログ** - 全ての IAM 変更を記録

---

## 6. CI/CD DESIGN

### 6.1 GitHub Actions - AWS デプロイ

```yaml
Trigger:
  - Push to main (paths: infra/aws/**, modules/aws/**)
  - Pull Request to main

Jobs:
  1. terraform-plan (PR時)
     - OIDC認証
     - terraform init & plan
     - Plan結果をPRコメント
  
  2. terraform-apply (main merge時)
     - 手動承認必須
     - OIDC認証
     - terraform apply
  
  3. build-and-push (main merge時)
     - ECRへログイン
     - Dockerイメージビルド
     - ECRへプッシュ
  
  4. deploy-ecs (main merge時)
     - ECS Service更新
     - デプロイ完了待機
  
  5. invalidate-cloudfront (main merge時)
     - CloudFront Distribution invalidation
```

**OIDC設定**:
```
Provider: token.actions.githubusercontent.com
Audience: sts.amazonaws.com
Condition: repo:owner/repo:ref:refs/heads/main
```

### 6.2 GitHub Actions - GCP デプロイ

```yaml
Trigger:
  - Push to main (paths: infra/gcp/**, modules/gcp/**)
  - Pull Request to main

Jobs:
  1. terraform-plan (PR時)
     - Workload Identity認証
     - terraform init & plan
     - Plan結果をPRコメント
  
  2. terraform-apply (main merge時)
     - 手動承認必須
     - Workload Identity認証
     - terraform apply
  
  3. build-and-push (main merge時)
     - Artifact Registryへ認証
     - Dockerイメージビルド
     - Artifact Registryへプッシュ
  
  4. deploy-cloud-run (main merge時)
     - Cloud Run Service更新
     - デプロイ完了待機
  
  5. purge-cdn (main merge時)
     - Cloud CDN cache purge
```

**Workload Identity設定**:
```
Provider: projects/{project-number}/locations/global/workloadIdentityPools/{pool-id}/providers/{provider-id}
Service Account: github-actions@{project}.iam.gserviceaccount.com
Attribute condition: attribute.repository == 'owner/repo'
```

### 6.3 Multi-Cloud Sync Check

```yaml
Trigger:
  - Pull Request (paths: infra/**, modules/**)

Checks:
  1. Module Parity
     - AWS modules と GCP modules の粒度一致確認
     - 不足しているモジュールを検出
  
  2. Infra Parity
     - infra/aws と infra/gcp の粒度一致確認
     - 対応するリソースの存在確認
  
  3. Naming Convention
     - ディレクトリ名の命名規則確認
     - ファイル名の統一確認
  
  4. Terraform Lint
     - terraform fmt check
     - tflint実行
  
  5. Security Scan
     - tfsec実行
     - checkov実行
```

**失敗条件**:
- モジュール粒度が一致しない
- 命名規則違反
- セキュリティリスク検出

### 6.4 Infracost統合

```yaml
Trigger:
  - Pull Request (terraform plan実行時)

機能:
  1. Cost Estimation
     - terraform plan から料金見積もりを生成
     - 月額コストを算出
     - 既存リソースとの差分コストを表示
  
  2. PR Comment
     - 自動でPRにコメント投稿
     - AWS/GCP別にコスト表示
     - リソース別のコスト内訳
  
  3. Cost Threshold (任意)
     - 一定額を超えた場合に警告
     - 承認プロセスの強制
```

**セットアップ**:
```bash
# Infracost API Key取得
# https://www.infracost.io/

# GitHub Secretsに設定
INFRACOST_API_KEY=ico-xxx
```

**PR コメント例**:
```
💰 Monthly Cost Estimate

AWS Resources:
  + VPC                 $0.00
  + NAT Gateway (2x)    $64.80
  + RDS (db.t3.micro)   $15.33
  + S3 (100GB)          $2.30
  ────────────────────────────
  Total:                $82.43/mo

GCP Resources:
  + VPC                 $0.00
  + Cloud NAT           $45.00
  + Cloud SQL (f1-micro) $9.37
  + GCS (100GB)         $2.00
  ────────────────────────────
  Total:                $56.37/mo

📊 Total Multi-Cloud Cost: $138.80/mo
```

---

## 7. MONITORING & LOGGING (Future)

### 7.1 Datadog 統合 (Coming Soon)

```
Dashboard配置: docs/datadog/
  ├── infrastructure.json
  ├── application.json
  └── security.json

Metrics:
  - AWS: CloudWatch Metrics
  - GCP: Cloud Monitoring Metrics
  - Custom: Application Metrics

Alerts:
  - ECS/Cloud Run Health
  - RDS/Cloud SQL Performance
  - ALB/Load Balancer 5xx errors
  - Lambda/Cloud Functions errors
```

---

## 8. SECURITY REQUIREMENTS

### 8.1 ネットワークセキュリティ

- **Private Subnet 必須** - データベース、アプリケーションは Private に配置
- **Security Group/Firewall Rule** - 必要最小限のポート開放
- **NAT Gateway 必須** - Private Subnet からのインターネットアクセス
- **VPC Peering 禁止** - 不要な VPC 間接続は作らない

### 8.2 データ保護

- **暗号化必須**
  - At Rest: S3, RDS, GCS, Cloud SQL
  - In Transit: TLS 1.2 以上
- **バックアップ**
  - RDS: 7日保持
  - Cloud SQL: 7日保持
  - S3/GCS: バージョニング有効
- **アクセス制御**
  - IAM/Service Account で最小権限
  - Public Access は原則禁止

### 8.3 監査

- **CloudTrail / Cloud Audit Logs**: 全て有効化
- **VPC Flow Logs**: 有効化
- **アクセスログ**:
  - ALB Access Log → S3
  - CloudFront Access Log → S3
  - Load Balancer Log → GCS

---

## 9. NAMING CONVENTIONS

### 9.1 リソース命名

```
形式: {environment}-{service}-{resource_type}-{suffix}

例:
- dev-app-vpc
- dev-app-subnet-public-a
- dev-app-ecs-cluster
- dev-app-s3-logs
- dev-app-rds-main
```

### 9.2 Terraform 変数命名

- **全て小文字**: スネークケース
- **明確な名前**: 略語は避ける
- **型指定**: 必ず type を明示

```hcl
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

---

## 10. CHANGE MANAGEMENT

### 10.1 変更フロー

1. **INSTRUCTION 更新**: 本ファイルに変更内容を記載
2. **Terraform 更新**: 仕様に基づいてコード生成
3. **PR作成**: GitHub で Pull Request
4. **自動チェック**: CI/CD が実行
5. **レビュー**: 承認
6. **手動 Apply**: `terraform apply` を手動実行
7. **確認**: リソースが正しく作成されたか確認

### 10.2 Terraform Apply 禁止事項

- **GitHub Actions での自動 apply 禁止**
- **plan のみ自動実行**
- **apply は必ず手動**
- **承認プロセス必須**

---

## 11. FUTURE ROADMAP

### Phase 1 (現在)
- [x] ディレクトリ構造確立
- [x] 基本モジュール作成 (VPC, ECR/Artifact Registry, S3/GCS)
- [x] CI/CD パイプライン構築

### Phase 2
- [ ] コンピューティング実装 (ECS, Cloud Run)
- [ ] ロードバランサー実装 (ALB, LB)
- [ ] データベース実装 (RDS, Cloud SQL)

### Phase 3
- [ ] CDN実装 (CloudFront, Cloud CDN)
- [ ] サーバーレス実装 (Lambda, Cloud Functions)
- [ ] ワークフロー実装 (Step Functions, Workflows)

### Phase 4
- [ ] Datadog 統合
- [ ] 監視・アラート設定
- [ ] セキュリティスキャン強化

---

## END OF INSTRUCTION

**本ファイルが全ての真実です。コードはこの仕様に従って生成されます。**
