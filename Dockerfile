FROM eclipse-temurin:17-jre AS runtime

ARG MODULE
ENV MODULE=${MODULE}
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms256m -Xmx512m -Dfile.encoding=UTF-8"

# 中文字体：电子证照 PDF 渲染必需（DroidSansFallbackFull.ttf 含 CJK 字形）。
# 注意镜像自带的 DejaVu 没有中文字形，PDType0Font 能加载但 showText 会抛
# "No glyph for U+XXXX"，因此不能用它兜底。
#
# 这里做成「尽力安装、失败不阻断构建」：基础镜像的 apt 源在部分网络环境下不可用
# （实测 archive.ubuntu.com 返回 503 且套件未签名），否则整个镜像都构建不出来。
# 若安装失败，可用运行时挂载字体 + GOV_PDF_FONT_PATH 指定路径来启用 PDF。
RUN apt-get update \
    && apt-get install -y --no-install-recommends fonts-droid-fallback \
    && rm -rf /var/lib/apt/lists/* \
    || echo "[warn] 中文字体安装失败（apt 源不可用）；如需证照 PDF，请挂载字体并设置 GOV_PDF_FONT_PATH"

WORKDIR /app
COPY ${MODULE}/target/${MODULE}-1.0.0.jar /app/app.jar

EXPOSE 8080
# 用 exec 让 JVM 直接成为 PID 1：原写法 JVM 是 sh 的子进程，收不到 SIGTERM，
# 容器重启时会被硬杀，Flowable/连接池无法优雅关闭。
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
