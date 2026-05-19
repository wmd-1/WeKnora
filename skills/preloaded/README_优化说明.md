# Writing Skill 优化说明

本版本重点优化：
1. 减少 prompt 重复规则
2. 强化 skill 路由边界
3. 明确 rewrite / factual / writing 三种模式
4. 降低过度检索问题
5. 增强长文生成稳定性
6. 强化结构优先策略
7. 提升实际生产环境中的可控性

## 推荐路由策略

优先按“输出目标”路由：
- 报告 → report-writing
- PPT → ppt-writing
- 公文 → gov-writing
- 演讲稿 → speech-writing
- 学术内容 → academic-writing
- 技术文档 → technical-writing
- 会议纪要 → meeting-summary
- 润色改写 → rewrite-polish

## 关键变化

### 1. rewrite 不再强制检索
用户只做润色时，直接写作即可。

### 2. retrieval 更轻量
只有事实、引用、数据、代码等场景才强制 chunk grounding。

### 3. skill 数量限制
每次最多 1-3 个 skill，避免 prompt 污染。

### 4. style control 独立
不同文体单独控制：
- executive
- academic
- gov
- speech
- ppt
- rewrite

### 5. fallback 增强
增加：
- 检索失败处理
- 信息缺失处理
- 不确定性标注

## Humanizer 接入说明

新增 `humanizer` skill 作为“最终润色层”：
- 先由 report / PPT / academic / speech / gov / technical 等主 skill 生成内容
- 再用 humanizer 去除 AI 写作痕迹
- 仅保留自然表达，不改事实、不改引用、不改代码

适用场景：
- 报告、论文、演讲稿、公告、总结、策略分析、改写润色

不适用场景：
- 代码、SQL、日志、精确引文、短事实问答
