# 东雲研究所

个人博客，记录学习与生活。

## 项目结构

```text
content/
  posts/              # 文章 Markdown
  posts/images/       # 文章封面和正文图片
  archives.md         # 归档页
archetypes/
  default.md          # 新文章模板
themes/
  PaperMod/           # Hugo PaperMod 主题，Git 子模块
hugo.yaml             # 站点配置
deploy.sh             # macOS/Linux 部署脚本
deploy.ps1            # Windows PowerShell 部署脚本
deploy.bat            # Windows 双击入口
```

## 快速开始

```bash
# 首次克隆后初始化主题
git submodule update --init --recursive

# 本地预览
hugo server -D

# 构建站点
hugo
```

本地预览默认地址通常是：

```text
http://localhost:1313/
```

如果 `1313` 被占用，可以指定端口：

```bash
hugo server -D --port 1314
```

## 新建文章

推荐使用 Hugo 命令创建文章，它会自动套用 `archetypes/default.md` 模板：

```bash
hugo new posts/my-new-post.md
```

文件名建议使用英文小写和短横线，例如：

```text
content/posts/my-new-post.md
```

由于 `hugo.yaml` 中配置了：

```yaml
permalinks:
  posts: "/:slug/"
```

文章最终地址会优先使用 Front Matter 中的 `slug`；如果没有设置 `slug`，通常会使用文件名生成地址。例如 `content/posts/my-new-post.md` 对应：

```text
https://electq.github.io/my-new-post/
```

## 文章信息

新文章头部会生成类似下面的 Front Matter：

```yaml
---
date: '2026-05-01T12:00:00+08:00'
draft: false
title: 'My New Post'
description: "文章摘要，会用于列表、SEO 和分享信息"
tags: ["Hugo", "博客"]
categories: ["技术"]
cover:
  image: "/posts/images/my-new-post-cover.jpg"
  alt: "封面图片说明"
  caption: "封面说明文字"
---
```

常用字段说明：

- `date`：发布时间。
- `draft`：是否草稿。`false` 会正常发布；`true` 只会在 `hugo server -D` 或构建带 `-D` 时出现。
- `title`：文章标题。
- `description`：文章摘要，建议每篇都填写。
- `tags`：标签，会自动进入 `/tags/` 索引。
- `categories`：分类，会自动进入 `/categories/` 索引。
- `cover.image`：封面图片路径。
- `cover.alt`：封面图片替代文本，建议填写。
- `cover.caption`：封面说明，可留空。

## 图片约定

文章相关图片统一放在：

```text
content/posts/images/
```

封面图片推荐命名：

```text
content/posts/images/my-new-post-cover.jpg
```

Front Matter 中这样引用：

```yaml
cover:
  image: "/posts/images/my-new-post-cover.jpg"
```

正文中引用图片：

```markdown
![图片说明](/posts/images/my-new-post-cover.jpg)
```

## 信息索引

当前站点会自动生成这些索引页面：

- `/posts/`：文章列表。
- `/tags/`：标签索引，来源于每篇文章的 `tags`。
- `/categories/`：分类索引，来源于每篇文章的 `categories`。
- `/archives/`：归档页，来源于 `content/archives.md` 和 PaperMod 的 `archives` layout。
- `/index.xml`、`/posts/index.xml`：RSS/XML 输出。

写文章时建议：

- 每篇文章至少设置一个 `tags`。
- `categories` 保持少而稳定，例如 `技术`、`随笔`、`生活`。
- `description` 写成 1 句话摘要，方便列表页和分享展示。
- 标签用于具体主题，分类用于大的内容归属。

### 可选：启用搜索页

当前 `hugo.yaml` 已包含 PaperMod 的 `fuseOpts` 搜索参数，但还没有启用搜索页和首页 JSON 索引。如果后续需要站内搜索，可以补充：

```yaml
outputs:
  home:
    - HTML
    - RSS
    - JSON

menu:
  main:
    - name: 搜索
      url: /search/
      weight: 50
```

并新增 `content/search.md`：

```markdown
---
title: "搜索"
layout: "search"
url: "/search/"
---
```

## 部署

Windows:

```bash
.\deploy.bat
```

Mac/Linux:

```bash
./deploy.sh
```

部署脚本会执行：

1. 同步远端 `origin/main`。
2. 构建 Hugo 站点。
3. 提交当前变更。
4. 推送到 GitHub。
5. 触发 GitHub Actions 部署到 GitHub Pages。

注意：部署脚本需要在 `main` 分支运行。
