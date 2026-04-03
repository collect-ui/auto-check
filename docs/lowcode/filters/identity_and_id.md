# 标识与ID Filters

## `uuid`
- 用法：生成标准 UUID
- 示例：`{{uuid}}`
- 注意：每次渲染都会变，避免在幂等更新主键重复调用

## `uuid_short`
- 用法：生成短 UUID（8位）
- 示例：`{{uuid_short}}`
- 注意：短 ID 碰撞概率高于标准 UUID，不建议做全局主键

## `snow_id`
- 用法：生成雪花 ID（int64）
- 示例：`{{snow_id}}`
- 注意：依赖节点配置，跨集群需保证 machine_id 唯一

## `genId`
- 用法：基于输入生成稳定短ID
- 示例：`{{genId .value}}`
- 注意：同输入可复现，适合派生 key
