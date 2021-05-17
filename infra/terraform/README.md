  ```bash
  # workspaceをdefaultに切り替える
  terraform workspace select default
  ```

  ```bash
  # remoteのstateファイルをpullし同期
  terraform init \
    -backend=true \
    -backend-config="bucket=sample.terraform" \
    -backend-config="key=sample.super.terraform.tfstate" \
    -backend-config="region=ap-northeast-1"
  ```

3. 同様に開発環境でのstateファイルも同期するため以下のコマンドを叩く

  ```bash
  # workspaceをdefaultに切り替える
  terraform workspace select dev

  # remoteのstateファイルをpullし同期
  terraform init \
    -backend=true \
    -backend-config="bucket=sample.terraform" \
    -backend-config="key=sample.development.terraform.tfstate" \
    -backend-config="region=ap-northeast-1"
  ```

4. 同様に本番環境でのstateファイルも同期するため以下のコマンドを叩く

  ```bash
  # workspaceをdefaultに切り替える
  terraform workspace select pro

  # remoteのstateファイルをpullし同期
  terraform init \
    -backend=true \
    -backend-config="bucket=sample.terraform" \
    -backend-config="key=sample.production.terraform.tfstate" \
    -backend-config="region=ap-northeast-1"
  ```

