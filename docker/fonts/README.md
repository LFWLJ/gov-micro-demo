# 中文字体（电子证照 PDF 用）

`gov-application` 生成电子证照 PDF 时需要一份**含 CJK 字形**的 TTF 字体。

## 为什么需要手动放

镜像里自带的 DejaVu 等西文字体**没有中文字形**：PDFBox 能加载成功，
但渲染中文时会抛 `IllegalArgumentException: No glyph for U+XXXX`。
`Dockerfile` 里已尝试 `apt-get install fonts-droid-fallback`，
但基础镜像的 apt 源在部分网络环境下不可用（实测 `archive.ubuntu.com` 返回 503），
因此做成「尽力安装、失败不阻断构建」。装不上时就用本目录挂载。

## 用法

1. 把一个中文 TTF 放进本目录，例如 `DroidSansFallbackFull.ttf`
   （来自 Debian 的 `fonts-droid-fallback` 包，也可用其它含 CJK 的 **TTF**）。

   > 注意必须是 **.ttf/.otf**。`.ttc` 字体集合 PDFBox 不能直接用 `PDType0Font.load` 加载。

2. 在项目根目录 `.env` 里指定容器内路径：

   ```
   GOV_PDF_FONT_PATH=/opt/gov/fonts/DroidSansFallbackFull.ttf
   ```

3. 重启 gov-application：

   ```powershell
   docker compose up -d gov-application
   ```

## 查找顺序

`LicensePdfUtil.loadFontBytes()` 依次尝试：

1. `-Dgov.pdf.font.path` 或环境变量 `GOV_PDF_FONT_PATH`（即上面的配置）
2. classpath `fonts/simhei.ttf`
3. 系统路径 `/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf`

三处都找不到时，会抛出**明确列出已尝试路径**的异常，而不是原来的
“字体文件 /fonts/simhei.ttf 未找到”这种不含线索的报错。
字体字节在进程内缓存，不会每次生成证照都重读整个文件。
