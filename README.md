# Infrastructure Spec-Driven Multi-Cloud

**`.github/instruction.md` を変更すれば、Terraformコードも自動で書き換わる世界へ。**

## 🎯 コンセプト

このリポジトリは **Spec-Driven Development** を採用しています。

### 仕組みは超シンプル

1. **`.github/instruction.md` に仕様を書く**
2. **GitHub Copilot が instruction を読んで Terraform コードを生成・修正**
3. **PR を出すと自動で plan 実行 + コスト見積もり**
4. **レビュー後、手動で apply**

### つまり？

- **コードではなく仕様を書く** → Copilot がコード化
- **instruction を変更** → Copilot が既存コードを修正
- **AWS と GCP の粒度を自動で揃える** → マルチクラウド対応が楽

## 🚀 使い方

### 1. instruction を変更する

```bash
# .github/instruction.md を編集
vim .github/instruction.md

# 例: VPC の CIDR を変更、新しいサブネットを追加、など
```

### 2. Copilot にコード生成・修正を依頼

```
@workspace .github/instruction.md に基づいて Terraform コードを更新してください
```

Copilot が自動で：
- 新しいモジュールを作成
- 既存のコードを修正
- AWS/GCP の両方に同じ粒度で適用

### 3. PR を出す

```bash
git checkout -b feature/update-vpc
git add .
git commit -m "Update VPC configuration per instruction.md"
git push origin feature/update-vpc
```

GitHub Actions が自動で：
- ✅ `terraform plan` 実行
- 💰 Infracost でコスト見積もり
- 📝 PR に結果をコメント

### 4. 手動で apply

```bash
cd infra/aws/network  # または infra/gcp/network
terraform apply
```

## 📖 重要なファイル

| ファイル | 役割 |
|---------|------|
| `.github/instruction.md` | **唯一の真実のソース (SSOT)** - すべての仕様はここに |
| `modules/*/` | 再利用可能な Terraform モジュール（Copilot が生成） |
| `infra/*/` | 実際にデプロイする構成（Copilot が生成） |
| `.github/workflows/` | CI/CD パイプライン（plan 自動実行） |

## 💡 具体例

### やりたいこと: VPC の CIDR を変更したい

**従来の方法:**
1. AWS の VPC コードを修正
2. GCP の VPC コードも修正
3. 変数ファイルを修正
4. outputs を修正
5. 依存関係を確認...

**Spec-Driven の方法:**
1. `.github/instruction.md` の VPC セクションで CIDR を変更
2. Copilot に「instruction に基づいて更新して」と依頼
3. 終わり

### やりたいこと: 新しい環境（staging）を追加したい

**従来の方法:**
1. dev のコードをコピー
2. 名前を変更
3. 変数を変更
4. backend を設定...

**Spec-Driven の方法:**
1. `.github/instruction.md` に staging 環境の仕様を追加
2. Copilot に「staging 環境を追加して」と依頼
3. 終わり

## 🎓 初めてのデプロイ

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-org/infra-spec-driven-multicloud.git
cd infra-spec-driven-multicloud

# 2. 変数ファイルを作成
cd infra/aws/network
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # 値を編集

# 3. デプロイ
terraform init
terraform plan
terraform apply
```

## ❓ FAQ

**Q: instruction を変更したら、コードは自動で更新される？**
A: GitHub Copilot に依頼する必要がありますが、ほぼ自動です。

**Q: 既存のコードを上書きしてもいい？**
A: はい！instruction が SSOT なので、コードは何度でも再生成可能です。

**Q: AWS と GCP で同じ構成を保つのは大変では？**
A: instruction に書けば、Copilot が両方のコードを同時に生成・修正します。

**Q: terraform apply は自動実行されない？**
A: はい。安全のため、apply は必ず手動実行です。

## 🔒 安全性

- **apply は手動のみ**: GitHub Actions は plan のみ実行
- **コスト見積もり**: Infracost が PR に自動コメント
- **変更前確認**: plan の結果を必ず確認してから apply

## 📚 さらに詳しく

- **設計思想**: [.github/instruction.md](.github/instruction.md) の「1. 本リポジトリの設計哲学」
- **命名規則**: [.github/instruction.md](.github/instruction.md) の「9. 命名規則」
- **セキュリティ**: [.github/instruction.md](.github/instruction.md) の「8. セキュリティ」

---

**💡 覚えること: `.github/instruction.md` を変更 → Copilot に依頼 → PR → apply**