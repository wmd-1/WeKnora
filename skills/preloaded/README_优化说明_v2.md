# 优化说明（v2）

这版主要修正了两个问题：

1. 路由表补全
   - 补上了 newsletter-writing
   - 补上了 humanizer 作为统一后处理层
   - 将所有 skill 都纳入按“输出目标”路由

2. skill 瘦身
   - 每个 skill 增加了更窄的职责边界
   - 强化了 report / executive-brief / strategy-analysis 的区分
   - 增加了 gov / speech / ppt / academic / technical / meeting / newsletter 的具体使用约束
   - 把 rewrite-polish 设为通用兜底
   - 把 humanizer 设为最终表层净化，不破坏事实与结构

## 推荐执行顺序

1. 识别输出目标
2. 选择 1 个主 skill
3. 如需改写，再叠加 rewrite-polish
4. 对最终 prose 做 humanizer 表层净化

## humanizer 适用范围

- 报告
- 简报
- 战略分析
- 学术写作
- 技术写作
- PPT 文案
- 演讲稿
- 会议纪要
- 周报/月报
- 公文
- 改写润色后的文本

## humanizer 例外

以下情况应跳过或强约束：
- 代码
- 精确引用
- 法律/合规原文
- 必须保留原句的文本
- 结构化数据表