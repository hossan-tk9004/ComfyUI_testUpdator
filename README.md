# ComfyUI Test Updator

`ComfyUI_testUpdator.bat` は、現在使用している ComfyUI Portable 環境を複製し、  
テスト用環境だけを ComfyUI の安定版へアップデートするためのバッチファイルです。

元の `ComfyUI_windows_portable` は更新せず、そのまま保持します。

## 配置

以下のように、`ComfyUI_testUpdator.bat` を `ComfyUI_windows_portable` と同じ階層に置いてください。

```text
<任意の配置先>\
├─ ComfyUI_testUpdator.bat
└─ ComfyUI_windows_portable\
```

## 使い方

1. ComfyUI を終了します。
2. `ComfyUI_testUpdator.bat` をダブルクリックして実行します。
3. 自動的に `ComfyUI_windows_portable_test` が作成されます。
4. テスト環境内の `update_comfyui_stable.bat` が実行され、ComfyUI が安定版へ更新されます。
5. 完了後、`ComfyUI_windows_portable_test` 側から ComfyUI を起動して動作確認してください。

実行後の構成は次のようになります。

```text
<任意の配置先>\
├─ ComfyUI_testUpdator.bat
├─ ComfyUI_windows_portable\
└─ ComfyUI_windows_portable_test\
```

## 共有されるフォルダ

容量節約のため、以下のフォルダはテスト環境へコピーされません。

```text
.\ComfyUI_windows_portable\ComfyUI\models
.\ComfyUI_windows_portable\ComfyUI\input
.\ComfyUI_windows_portable\ComfyUI\output
```

代わりに、テスト環境側には元環境を参照する **ジャンクション** が作成されます。

そのため、元環境とテスト環境では以下のデータを共有します。

- モデル
- input 画像・ファイル
- output 画像・ファイル

## 注意事項

`models`、`input`、`output` は元環境とテスト環境で同じ実体を参照しています。

そのため、テスト環境側からこれらのフォルダ内のファイルを削除・変更すると、元環境側にも反映されます。

一方、以下はテスト環境側に複製されるため、元環境とは独立しています。

- ComfyUI 本体
- `custom_nodes`
- `python_embeded`
- その他の Portable 環境内ファイル

## 再作成する場合

すでに `ComfyUI_windows_portable_test` が存在する場合、バッチは安全のため処理を中断します。

新しくテスト環境を作り直す場合は、

1. 必要なデータがないことを確認
2. `ComfyUI_windows_portable_test` を削除、または別名へ変更
3. `ComfyUI_testUpdator.bat` を再実行

してください。

## 想定用途

ComfyUI のアップデート前に現在の環境を残しておき、最新版の安定版で以下を確認する用途を想定しています。

- ComfyUI が正常に起動するか
- Custom Node が正常に動作するか
- 既存 Workflow が壊れていないか
- 画像生成が正常に行えるか

問題があった場合は、元の `ComfyUI_windows_portable` をそのまま使用できます。
