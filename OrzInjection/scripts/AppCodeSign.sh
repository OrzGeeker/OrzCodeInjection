#!/usr/bin/env bash
#-*- coding: utf-8 -*-

# ${SRCROOT} 为工程文件所在的目录
TEMP_PATH="${SRCROOT}/Temp"

# 资源文件夹,放三方APP砸壳后的ipa包
ASSETS_PATH="${SRCROOT}/APP-decrypted"

# 只选择目录下第一个ipa包
FIRST_IPA_PATH="$(ls ${ASSETS_PATH}/*.ipa | head -n 1)"
TARGET_IPA_PATH="${ASSETS_PATH}/${FIRST_IPA_PATH##*/}"

# 清空Temp目录及其下的历史产物，并新建Temp空文件夹
rm -rf "$TEMP_PATH"
mkdir -p "$TEMP_PATH"

# --------------------------------------
# 解压IPA 到Temp下(解压缩时覆盖同名文件，并不输出日志到控制台-oqq)
unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"

# 拿到解压的临时APP的路径
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app;echo "$1")
# 这里显示打印一下 TEMP_APP_PATH变量
echo "✅ TEMP_APP_PATH: $TEMP_APP_PATH"

# -------------------------------------
# 把解压出来的.app拷贝进去
# BUILT_PRODUCTS_DIR 工程生成的APP包路径
# TARGET_NAME target名称
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
echo "✅ TARGET_APP_PATH: $TARGET_APP_PATH"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH/"

# 拷完后，销毁临时目录
rm -rf $TEMP_PATH

# -------------------------------------
# 为了是重签过程简化，移走extension和watchAPP. 此外个人免费的证书没办法签extension

echo "✅ Removing AppExtensions"
rm -rf "$TARGET_APP_PATH/PlugIns"
rm -rf "$TARGET_APP_PATH/Watch"
find "$TARGET_APP_PATH" -type dir -name "com.*" | xargs -I {} rm -rf {}

# -------------------------------------
# 更新 Info.plist 里的BundleId
# 设置 "Set :KEY Value" "目标文件路径.plist"
PLIST_TOOL_BIN="/usr/libexec/PlistBuddy"
$PLIST_TOOL_BIN -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"

# 设置应用的名称
DUMMY_DISPLAY_NAME=$($PLIST_TOOL_BIN -c "Print CFBundleDisplayName"  "${SRCROOT}/$TARGET_NAME/Info.plist")
DUMMY_DISPLAY_NAME="🦄"
TARGET_DISPLAY_NAME=$($PLIST_TOOL_BIN -c "Print CFBundleDisplayName"  "$TARGET_APP_PATH/Info.plist")
TARGET_DISPLAY_NAME="$DUMMY_DISPLAY_NAME$TARGET_DISPLAY_NAME"
$PLIST_TOOL_BIN -c "Set :CFBundleDisplayName $TARGET_DISPLAY_NAME" "$TARGET_APP_PATH/Info.plist"

# 设置支持安装的设备类型
support_devices=("iPhone12,5" "iPhone12,3" "iPhone12,1" "iPhone11,8" "iPhone11,6" "iPhone11,4" "iPhone11,2" "iPhone10,6" "iPhone10,5" "iPhone10,4" "iPhone10,3" "iPhone10,1" "iPhone10,4" "iPhone6,1" "iPhone6,2" "iPhone7,2" "iPhone8,1" "iPhone8,4" "iPhone9,1" "iPhone9,3" "iPod7,1")
for device in ${support_devices[@]}
do
$PLIST_TOOL_BIN -c "Add :UISupportedDevices: string $device" "$TARGET_APP_PATH/Info.plist"
done

# 给可执行文件上权限
# 找到第三方app包里的可执行文件名称，因为Info.plist的 CFBundleExecutable 对应的是可执行文件的名称
APP_BINARY=$($PLIST_TOOL_BIN -c "Print CFBundleExecutable"  "${TARGET_APP_PATH}/Info.plist")
# 为App二进制文件加上可执行权限+X, 否则Xcode会告知无法运行
chmod +x "$TARGET_APP_PATH/$APP_BINARY"

# -------------------------------------
# 注入Framework
YOLOLIB_BIN="${SRCROOT}/Tools/yololib"

FRAMEWORKS_TO_INJECT_PATH="${SRCROOT}/Frameworks-inject"
TARGET_APP_FRAMEWORKS_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/Frameworks"
for file in `ls -1 "${FRAMEWORKS_TO_INJECT_PATH}"`; do
    extension="${file##*.}"
    if [ "$extension" != "framework" ]
    then
        continue
    fi

    mkdir -p "$TARGET_APP_FRAMEWORKS_PATH"
    rsync -av --exclude=".*" "${FRAMEWORKS_TO_INJECT_PATH}/$file" "$TARGET_APP_FRAMEWORKS_PATH"
    filename="${file%.*}"

    $YOLOLIB_BIN "$TARGET_APP_PATH/$APP_BINARY" "Frameworks/${file}/${filename}"
done
ORZ_HOOK_FRAMEWORK_PATH="$BUILT_PRODUCTS_DIR/OrzHook.framework"
cp -Rf $ORZ_HOOK_FRAMEWORK_PATH $TARGET_APP_FRAMEWORKS_PATH
$YOLOLIB_BIN "$TARGET_APP_PATH/$APP_BINARY" "Frameworks/OrzHook.framework/OrzHook"

# -------------------------------------
# 6. 重签第三方app Frameworks下已存在的动态库
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
#遍历出所有动态库的路径
    for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
    do
        echo "🍺 FRAMEWORK : $FRAMEWORK"
        #签名
        /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
    done
fi

if [ $? -eq 0 ]; then
    echo "✅ App Code Sign Completed"
fi

# --------------------------------------------
# 创建可分发的IPA
IPA_PRODUCT_PATH="${SRCROOT}/ipa-dist"
IPA_PRODUCT_PAYLOAD_PATH="${IPA_PRODUCT_PATH}/Payload"
rm -rf "${IPA_PRODUCT_PATH}"
mkdir -p "${IPA_PRODUCT_PATH}" "${IPA_PRODUCT_PAYLOAD_PATH}"
cp -rf "$TARGET_APP_PATH" "$IPA_PRODUCT_PAYLOAD_PATH"
cd "$IPA_PRODUCT_PATH"
zip -qr "${TARGET_DISPLAY_NAME}.ipa" "Payload/"
rm -rf "$IPA_PRODUCT_PAYLOAD_PATH"
if [ $? -eq 0 ]; then
    echo "✅ IPA Created!!"
fi
