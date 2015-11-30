# Jedi
I wanna be a Jedi Knight.



# Dependencies

- [Processing](https://processing.org/)
- [OpenKinect for Processing](https://github.com/shiffman/OpenKinect-for-Processing)
- [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing)
- [SimpleOpenNI](https://code.google.com/p/simple-openni/)


# 開発環境の構築
## 推奨環境
開発に必要な OS は UNIX です．
Mac を持っていない人は適当な Linux をインストールしてください．

初心者には [\[お察しください\]ntu](https://www.ubuntulinux.jp/) がいいと思いますが，これから本格的にプログラミングをしていくであろう情報の学生には [Arch Linux](https://www.archlinux.org/) をおすすめします．

UNIX を使って開発を行いたい人は [@y-sira](https://github.com/y-sira) に聞いてください．
OS のインストールから開発環境を整えるまでサポートします．

基本的には [これだけ](http://qiita.com/sira/items/1fca78d1185a4e5997d9) です．


## Windows（非推奨）
実行はできないけど，コードを書くだけでもやりたい！という人は Windows でも大丈夫です．

Processing は [ここ](https://processing.org/) からダウンロードできます．

各種ライブラリは

- [OpenKinect for Processing](https://github.com/shiffman/OpenKinect-for-Processing)
- [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing)

からダウンロードして，ディレクトリ `Processing/liblaries` に配置してください．

Git の導入は Cygwin から行えます．
詳しくは [@526mapleleaf](https://github.com/526mapleleaf) に．



# 開発の流れ
## 怖くない！ GitHub で共同開発 基礎編
リポジトリをクローン（ソースコードをダウンロード）してきます．

```
$ git clone https://github.com/y-sira/gu-jedi.git
```

適当な名前のブランチ（作業スペース）を作ってチェックアウト（移動）し，

```
$ git checkout -b <branch_name>
```

作業（Processing IDE で実際にコードを書く）します．

作業が完了したら，変更したファイルをすべて登録します．

```
$ git add <file_name> <file_name> ...
```

登録漏れがないかを確認し，

```
$ git diff
```

コミット（複数のファイル変更をまとまりとして定義し，全体で何を実現したかがわかるようにコメントを付ける作業）します．

```
$ git commit -m "ここをこうやって変更した"
```

続けて作業を行う場合は，同様に `git add` から `git commit` までの内容を繰り返してください．

最後に必ずプッシュ（ここまでの変更をサーバーにアップロード）します．

```
$ git push
```

※ 初回の `git push` 時は怒られるので，メッセージに従って `git push xxx` しましょう．



## その他の操作
### ブランチの移動

```
$ git checkout <branch_name>
```


### ソースコードを最新状態に更新
`origin/master` はサーバー上にある最も新鮮なブランチ，`master` は `git clone` した時点で最新__「だった」__ローカルにあるブランチ．

ここでは `master` を `origin/master` の最新状態に更新する方法を紹介します．

`master` ブランチに移動し，

```
$ git checkout master
```

最新の状態に更新します．

```
$ git fetch
$ git merge origin/master
```


### ブランチの分岐地点を更新
ブランチを切った時点から `origin/master` ブランチで開発が進んでしまい，そのままではマージ（変更を `origin/master` に統合）できず，リベース（自分の作ったブランチのベースとなる `master` ブランチを最新の状態に）したい場合があります．

そんな時は `master` ブランチを最新の状態に更新してから，リベースしたいブランチに移動し，

```
$ git checkout <branch_name>
```

分岐元を最新状態である `master` ブランチに変更します．

```
$ git rebase master
```

コンフリクト（変更の衝突）が起きた場合は呼んでください．
以下のように，手動でコンフリクトを直していく必要があります．

```
$ git add <confricts_fixed_file_name> <confricts_fixed_file_name> ...
$ git rebase --continue
$ git push
```


## 注意点

- `master` ブランチではコードの変更を行わないこと．
- `master` ブランチはできるだけ最新の状態に保つようにすること．
- 細かく `git commit` すること．
- 休憩に入る前に `git push` してサーバーに反映させていないコミットが残らないようにすること．
- 簡単のため，いろいろ誤魔化して書いてます．
