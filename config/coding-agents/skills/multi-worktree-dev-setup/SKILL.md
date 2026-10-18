---
name: multi-worktree-dev-setup
description: >-
  同一リポジトリの複数の git worktree を同時に起動しても、バックエンド／フロントエンドのポートやDocker コンテナ名が
  衝突しないローカル開発環境を、ENV_NO という1つの環境変数だけで分離して構築する。
  追跡ファイル（コミット対象）は一切変更しない。
---

# git worktree ごとにポートを分離したローカル開発環境を構築する

これは、対象リポジトリで、複数の `git worktree` を同時に起動しても
バックエンド／フロントエンドのポートや Docker コンテナ名が衝突しないローカル開発環境を、
**追跡ファイル（コミット対象）を一切変更せずに** 構築するための手順書。

---

## 目的（前提）

- 同一リポジトリの複数 worktree を並行して開発・起動したい。
- ポートやコンテナ名の衝突を、`ENV_NO`（環境番号）という1つの環境変数だけで一括回避したい。
- リポジトリ本体（tracked files）は変更しない。すべて **git 管理外のローカルファイル** で完結させる。
- worktree 間で「内容が同一のファイル」は **symlink で共有**し、環境ごとに異なる設定だけを実体ファイルにする。

## 設計の全体像

| ファイル                      | 役割                                                                                                  | 共有方法                                       |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `GNUmakefile`                 | `ENV_NO` からポート/プロジェクト名を算出し、backend 起動・frontend 起動・停止の make ターゲットを提供 | 全 worktree で同一 → **symlink 共有**          |
| `docker-compose.override.yml` | ポート/コンテナ名を上書き                                                                             | 全 worktree で同一 → **symlink 共有**          |
| `.env`                        |                                                                                                       | 全 worktree で同一 → **symlink 共有**          |
| `GNUmakefile.local`           | その worktree の `ENV_NO` だけを定義                                                                  | worktree ごとの **実体ファイル**（共有しない） |

- ポート採番: `BACKEND_PORT = <BACKEND_BASE_PORT> + ENV_NO`、`FRONTEND_PORT = <FRONTEND_BASE_PORT> + ENV_NO`。
  compose に DB 等の追加サービスがあり同時起動させたい場合は、そのサービスにも同様に
  `<SERVICE>_PORT = <SERVICE_BASE_PORT> + ENV_NO` を採番する（例 `PG_PORT = 5432 + ENV_NO`）。
- コンテナ名衝突は `COMPOSE_PROJECT_NAME = <PROJECT_PREFIX>-$(ENV_NO)` と override の `container_name: !reset null` で回避。
- git 除外は **`.git/info/exclude`**（tracked な `.gitignore` を汚さない）。
- ファイル名は **`Makefile` ではなく必ず `GNUmakefile`** にする。

---

## STEP 0: 対象リポジトリの調査（まず必ず実施）

以下を調べ、後続のプレースホルダを確定させる。

1. `git worktree list`:
   - 対象 worktree 群
   - **メイン worktree**（通常は最初の 1 つ）= 共有ファイルの実体を置き、他の worktree が symlink で参照する先
2. `docker-compose.yml` / `compose.yaml` の有無と内容:
   - サービス名（例 `fastapi`）= `<SERVICE_NAME>`
   - `ports:` のホスト側ポート = `<BACKEND_DEFAULT_PORT>`（override の `:-` デフォルトに使う）
   - `container_name:` の有無（あれば override で `!reset null` する）
3. フロントエンドの起動方法。**まず compose のサービスかホスト実行かを判定する**:
   - **compose サービスの場合**
     - backend と同じく override で `ports` / `container_name` を分離する
     - `FRONTEND_PORT` を環境変数として export する
     - backend URL は compose の `environment:` を override して注入する
   - **ホスト実行の場合**
     - dev サーバ起動コマンド（例 `pnpm dev`）
     - ポート指定フラグ（Next.js/Vite は `-- -p <port>` または `--port`）
     - 参照する backend URL の環境変数名 = `<FRONTEND_BACKEND_URL_ENV>`（例 `NEXT_PUBLIC_API_URL`、`VITE_API_URL`）
4. 既存の `.gitignore` / `.git/info/exclude`:
   - これから作るファイルが既に無視されるか
5. 採番の基準値（既存の使用ポートと衝突しない値）:
   - `<BACKEND_BASE_PORT>`（例 `8000`）
   - `<FRONTEND_BASE_PORT>`（例 `3000`）
   - `<PROJECT_PREFIX>`（例 `<repo-short-name>`）

> 対象にバックエンドが無い／フロントエンドが無い場合は、該当セクションを省略してよい。

---

## STEP 1: メイン worktree に共有ファイルの実体を作成

### 1-1. `docker-compose.override.yml`（compose がある場合）

```yaml
services:
  <SERVICE_NAME>:
    # 固定コンテナ名を解除し、COMPOSE_PROJECT_NAME 由来の自動命名にする（worktree 間の名前衝突回避）
    # 元の compose に container_name が無ければこの行は不要
    container_name: !reset null
    # ポートは追記ではなく置換する（!override が無いと元の "PORT:PORT" が残り衝突する）
    ports: !override
      - "${BACKEND_PORT:-<BACKEND_DEFAULT_PORT>}:<CONTAINER_PORT>"
  # DB 等、他に container_name / ports が固定されているサービスがあれば同様に列挙する
  <OTHER_SERVICE_NAME>:
    container_name: !reset null
    ports: !override
      - "${<OTHER_SERVICE>_PORT:-<OTHER_SERVICE_DEFAULT_PORT>}:<OTHER_CONTAINER_PORT>"
```

### 1-2. `GNUmakefile`

```makefile
# ここで ENV_NO 等を上書きすると make xxx だけで効く。
-include GNUmakefile.local

ENV_NO ?= 0

# STEP 0 で決めた基準値（全 worktree 共通）
BACKEND_BASE_PORT ?= 8000
FRONTEND_BASE_PORT ?= 3000

BACKEND_PORT ?= $(shell echo $$(($(BACKEND_BASE_PORT) + $(ENV_NO))))
FRONTEND_PORT ?= $(shell echo $$(($(FRONTEND_BASE_PORT) + $(ENV_NO))))
COMPOSE_PROJECT_NAME ?= <PROJECT_PREFIX>-$(ENV_NO)
BACKEND_URL ?= http://localhost:$(BACKEND_PORT)

export BACKEND_PORT
export COMPOSE_PROJECT_NAME

.PHONY: up
up:
 docker compose up

.PHONY: up/build
up/build:
 docker compose up --build

.PHONY: down
down:
 docker compose down

.PHONY: frontend
frontend:
 cd <FRONTEND_DIR> && <FRONTEND_BACKEND_URL_ENV>=$(BACKEND_URL) <FRONTEND_DEV_CMD> -- <PORT_FLAG> $(FRONTEND_PORT)
```

- 上記 `frontend` ターゲットは **frontend をホストで直接起動する場合**のもの。
  frontend も compose サービスなら `frontend` ターゲットは不要で、代わりに override 側で
  `ports` / `container_name` / `environment`（backend URL）を分離し、`export FRONTEND_PORT` を追加する。
- `<FRONTEND_DEV_CMD>` 例: `pnpm dev`。
- `<PORT_FLAG>` 例: `-p`（Vite は `--port`）。
- `<FRONTEND_BACKEND_URL_ENV>` 例: `NEXT_PUBLIC_API_URL`。
- `<FRONTEND_DIR>` は実際のパスに合わせる（例 `frontend` / `web`、モノレポなら該当パス）。
- **tracked `Makefile` への委譲**
  - `GNUmakefile` があると make は tracked `Makefile` を読まなくなるため、既存ターゲットを潰さないよう末尾に以下を入れておく（`Makefile` が無ければ何も起きない）。

```makefile
ifneq ($(wildcard Makefile),)
# GNUmakefile で定義していないターゲットは tracked Makefile に委譲する
%::
 @$(MAKE) -f Makefile $@
endif
```

---

## STEP 2: git 除外に追記（メイン worktree で 1 回）

`.gitignore`（tracked）ではなく `.git/info/exclude` に追記する。worktree 間で共有される。

```bash
printf '%s\n' GNUmakefile GNUmakefile.local docker-compose.override.yml >> "$(git rev-parse --git-common-dir)/info/exclude"
```

- 追記前に重複しないよう既存内容を確認すること。

---

## STEP 3: 各 worktree をセットアップ

メイン worktree の実体ファイルに対して、他の worktree から **相対 symlink** を張る。`GNUmakefile.local` だけは各 worktree の実体。

```bash
MAIN_REL="<各 worktree から見たメインへの相対パス>"

i=1
for WT in <他 worktree のパス...>; do
  ln -sfn "$MAIN_REL/GNUmakefile"                 "$WT/GNUmakefile"
  ln -sfn "$MAIN_REL/docker-compose.override.yml" "$WT/docker-compose.override.yml"
  ln -sfn "$MAIN_REL/.env"                        "$WT/.env"
  printf 'ENV_NO = %d\n' "$i" > "$WT/GNUmakefile.local"
  i=$((i + 1))
done
```

- メイン worktree にも `GNUmakefile.local`（`ENV_NO = <メインの番号>`）を置く。
- `ENV_NO` は worktree 間で重複しないこと

---

## STEP 4: 検証（すべて満たすこと）

各 worktree で:

1. **make 展開**: `make -C <WT> -n frontend` の出力が以下を含む
   - `<FRONTEND_BACKEND_URL_ENV>=http://localhost:<BACKEND_BASE_PORT+N>`
   - `<PORT_FLAG> <FRONTEND_BASE_PORT+N>`
2. **compose 解決**: worktree ディレクトリで
   `BACKEND_PORT=<BACKEND_BASE_PORT+N> COMPOSE_PROJECT_NAME=<PREFIX>-<N> docker compose config` を実行し、以下を確認
   - `published: "<BACKEND_BASE_PORT+N>"`
   - プロジェクト名が `<PREFIX>-<N>`
   - `container_name` が消えている（または一意になっている）
3. **git クリーン**: `git -C <WT> status --short` が空
   - symlink も `GNUmakefile.local` も追跡されない
4. **symlink**: `ls -l <WT>/GNUmakefile` 等がメイン worktree を指している

---

## 適用時の判断メモ

- **compose が無い / backend が無い**: override・`.env`・`up` 系ターゲットを省略し、frontend だけ構成する。
- **frontend が無い**: `frontend` ターゲットと `FRONTEND_*`/`BACKEND_URL` を省略する。
- **モノレポ / 複数サービス**: override に複数 `services:` を並べ、GNUmakefile のターゲットを増やす。
