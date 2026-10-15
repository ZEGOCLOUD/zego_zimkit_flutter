# Android Chat Message List Initial Position Implementation Plan

状态：已完成（全量测试仍有 3 个既有录音用例失败）

基准：ZIMKit Flutter v2.0.1（2026-10-15 与源码核对）

**Goal:** 打开聊天时，首个可见消息列表画面直接位于最新消息，不闪现历史列表开头。

**Architecture:** 保留现有首帧定位流程，在列表完成首次跳转前用不透明遮罩盖住消息内容。默认遮罩使用消息列表背景色，并继续叠加调用方的自定义背景。用消息列表组件的 Widget 测试覆盖首次定位遮罩，并同步组件文档。

**Tech Stack:** Flutter、Dart、`flutter_test`。

**Spec:** 用户提供的视频 `/Volumes/adam/projects/uikits/temp/飞书20261015-121326.qt` 和本次缺陷描述。

## 全局约束

- 保留工作区中与本缺陷无关的未提交改动。
- 先补回归测试，再修改组件。
- 只改首次定位遮罩及其对应测试、文档。
- 完成后使用独立 Agent 审查代码。

## Review Focus

- 首次数据加载尚未完成跳转时，遮罩必须完整覆盖首屏消息内容；Widget 测试检查遮罩尺寸及不透明底色。
- 自定义 `backgroundBuilder` 在遮罩期间仍需显示在列表背景色之上；Widget 测试检查自定义背景仍被构建。
- 首次定位完成后必须撤掉遮罩并显示最新消息；Widget 测试检查遮罩隐藏且最新消息可见。

---

### Task 1: 修复消息列表首次定位遮罩

**文件：**
- 修改：`lib/src/components/messages/list/widget.dart`
- 测试：`test/review_regressions_test.dart`
- 文档：`doc/components.md`

- [x] 在现有回归测试中添加 `chat message list hides history until initial scroll completes` Widget 测试：预置已初始化的聊天消息列表，验证首次定位期间遮罩有不透明背景、覆盖整个列表视口且自定义背景仍构建；定位完成后遮罩隐藏、最新消息可见。
- [x] 运行 `flutter test test/review_regressions_test.dart --plain-name 'chat message list hides history until initial scroll completes'`；原实现按预期因遮罩透明失败。
- [x] 修改 `scrollMask`，用 `ZIMKitMessageStyle.messageListBackgroundColor` 填满遮罩，并将自定义 `backgroundBuilder` 叠加在其上。
- [x] 重跑针对性测试和完整 Flutter 测试套件；目标回归测试通过，完整套件仍为 78 项通过、3 项基线录音测试失败。
- [x] 在 `doc/components.md` 的消息列表说明中记录打开聊天时从最新消息开始显示；核对文档基准日期已是当前日期 `2026-10-15`。
- [x] 复查最终 diff，确认无关改动未被修改，并完成独立 Agent 代码审查。

## 验证

`flutter test test/review_regressions_test.dart` 通过（5/5）；`flutter analyze` 无问题；`git diff --check` 通过。完整 `flutter test` 为 78 项通过、3 项失败，失败项与改动前基线一致，均在 `test/message_input_voice_mode_test.dart` 的录音流程。

## 审查

独立代码审查未发现问题。审查确认遮罩覆盖完整视口、背景不透明、自定义背景保留，定位完成后显示最新消息。
