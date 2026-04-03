#!/usr/bin/env python3
import re
import sqlite3
from pathlib import Path
import yaml

ROOT = Path('/data/project/auto-check')
ROUTER = ROOT / 'collect/service_router.yml'
FILTER_REGISTER = Path('/data/project/collect/src/collect/filters/all_register.go')
FILTER_DIR = Path('/data/project/collect/src/collect/filters')
DB = Path('/data/project/sport/database/price.db')
OUT = ROOT / 'docs/lowcode'


def read_yaml(path: Path):
    return yaml.safe_load(path.read_text(encoding='utf-8'))


def parse_filters_register(path: Path):
    text = path.read_text(encoding='utf-8')
    return re.findall(r'"([A-Za-z0-9_]+)"\s*:\s*([A-Za-z0-9_]+)', text)


def parse_go_signature(func_name: str):
    pattern = re.compile(rf"func\s+{re.escape(func_name)}\s*\((.*?)\)\s*(.*?)\s*\{{", re.S)
    for go in FILTER_DIR.glob('*.go'):
        if go.name == 'all_register.go':
            continue
        text = go.read_text(encoding='utf-8')
        m = pattern.search(text)
        if m:
            args = ' '.join(m.group(1).split())
            ret = ' '.join(m.group(2).split()) or 'void'
            return f"{func_name}({args}) {ret}", go
    return f"{func_name}(...)", None


def fetch_doc_rows():
    conn = sqlite3.connect(str(DB))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute("""
        select collect_doc_id,title,type,parent_dir,ifnull(is_delete,'0') is_delete,
               ifnull(code,'') code, ifnull(code_desc,'') code_desc
        from collect_doc
        where ifnull(is_delete,'0')='0'
    """)
    docs = [dict(r) for r in cur.fetchall()]
    conn.close()
    return docs


def fetch_doc_detail_counts(collect_doc_id: str):
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    out = {}
    for t in ['collect_doc_important', 'collect_doc_params', 'collect_doc_demo', 'collect_doc_result']:
        cur.execute(f"select count(1) from {t} where collect_doc_id=?", (collect_doc_id,))
        out[t] = cur.fetchone()[0]
    conn.close()
    return out


FILTER_HELP = {
    'uuid': ('生成标准 UUID', '{{uuid}}', '每次渲染都会变，避免在幂等更新主键重复调用'),
    'uuid_short': ('生成短 UUID（8位）', '{{uuid_short}}', '短 ID 碰撞概率高于标准 UUID，不建议做全局主键'),
    'is_empty': ('判断值是否为空（空串/空数组/null）', '{{is_empty .value}}', '返回布尔值，常用于 if_template'),
    'must': ('判断值是否非空', '{{must .value}}', '与 is_empty 互补，常用于参数必填校验'),
    'current_date_time': ('返回当前时间字符串', '{{current_date_time}}', '格式受后端实现控制，通常 yyyy-MM-dd HH:mm:ss'),
    'current_date_format': ('按格式返回当前时间', '{{current_date_format "20060102"}}', '格式使用 Go time layout 规则'),
    'replace': ('字符串全量替换', '{{replace .s ":" ""}}', '仅处理字符串参数'),
    'md5': ('计算字符串 MD5', '{{md5 .password}}', '仅用于摘要，不用于安全加密存储'),
    'sub_str': ('字符串切片，支持负索引', '{{sub_str .s -6 -1}}', '索引越界会触发运行错误，先保证长度'),
    'get_key': ('读取系统配置 key', '{{get_key "wechat_schedule_enable"}}', '依赖配置中心，key 不存在返回空'),
    'pinyin': ('中文转拼音', '{{pinyin .name}}', '多音字按库默认规则转换'),
    'hash_sha': ('生成 SSHA 哈希', '{{hash_sha .password}}', '用于 LDAP 风格哈希，不等同 bcrypt'),
    'snow_id': ('生成雪花 ID（int64）', '{{snow_id}}', '依赖节点配置，跨集群需保证 machine_id 唯一'),
    'index': ('查找子串位置', '{{index .s "abc"}}', '找不到返回 -1'),
    'unix_time': ('返回 Unix 秒级时间戳（可带偏移）', '{{unix_time -1 `day`}}', '秒级；如需毫秒需手动 *1000'),
    'unix_time2datetime': ('Unix 秒转时间字符串', '{{unix_time2datetime .ts}}', '输入应为秒级 int64'),
    'contains': ('判断数组是否包含某值', '{{contains .arr .target}}', '数组元素类型需可直接比较'),
    'to_json': ('对象转 JSON 字符串', '{{to_json .obj}}', '序列化失败会返回空串'),
    'cast': ('类型转换 int/int64/float/float64', '{{cast .value "int64"}}', '不支持的类型原样返回'),
    'multiply': ('乘法，返回保留2位小数字符串', '{{multiply 2 3}}', '返回字符串，不是数字类型'),
    'divide': ('除法，返回保留2位小数字符串', '{{divide 10 4}}', '除数为 0 风险需在外层避免'),
    'sub_arr': ('二维结构中取子数组字段', '{{sub_arr .arr 0 "[children]"}}', '索引越界会异常，先判断长度'),
    'range_number': ('生成 0..n-1 数组', '{{range_number 5}}', '常配合 foreach 生成固定次数循环'),
    'sub_arr_attr': ('二维结构取某元素属性', '{{sub_arr_attr .arr 0 "[children]" 1 "name"}}', '越界时返回空串或"0"（按实现）'),
    'str_contains': ('字符串包含判断', '{{str_contains .s "@chatroom"}}', '区分大小写'),
    'random_int': ('生成随机整数[min,max]', '{{random_int 1 10}}', '每次渲染都会变化，不适合幂等字段'),
    'first_item': ('取数组第一个元素', '{{first_item .arr}}', '空数组会越界，先用 must 判断'),
    'concat': ('拼接多个字符串', '{{concat .a .b .c}}', '参数需为字符串'),
    'genId': ('基于输入生成稳定短ID', '{{genId .value}}', '同输入可复现，适合派生 key'),
    'join': ('数组按分隔符拼接', '{{join .arr ","}}', '实现中会把元素断言为 string'),
    'date_format': ('时间字符串格式化为 yyyy-MM-dd HH:mm:ss', '{{date_format .timeStr "2006-01-02T15:04:05Z07:00"}}', '解析失败返回空串'),
}

CATEGORY = {
    'identity_and_id': ['uuid', 'uuid_short', 'snow_id', 'genId'],
    'time_and_date': ['current_date_time', 'current_date_format', 'unix_time', 'unix_time2datetime', 'date_format'],
    'string_and_text': ['replace', 'sub_str', 'str_contains', 'concat', 'join', 'pinyin', 'md5', 'hash_sha', 'index'],
    'array_and_object': ['contains', 'sub_arr', 'sub_arr_attr', 'range_number', 'first_item', 'to_json'],
    'math_and_cast': ['cast', 'multiply', 'divide', 'random_int'],
    'runtime_and_guard': ['must', 'is_empty', 'get_key'],
}

CATEGORY_TITLE = {
    'identity_and_id': '标识与ID',
    'time_and_date': '时间与日期',
    'string_and_text': '字符串与文本',
    'array_and_object': '数组与对象',
    'math_and_cast': '数值与类型',
    'runtime_and_guard': '运行时与校验',
}


def gen_filter_registry(filters, docs):
    by_title = {d['title']: d for d in docs}
    lines = ['# Filter 注册与用法总览', '', '来源：`/data/project/collect/src/collect/filters/all_register.go`', '', f'总数：`{len(filters)}`', '']
    for key, fn in filters:
        sig, src = parse_go_signature(fn)
        desc, ex, pit = FILTER_HELP.get(key, ('见源码实现', f'{{{{{key}}}}}', '请按源码确认参数类型'))
        doc_row = by_title.get(key)
        lines.append(f"## `{key}`")
        lines.append(f"- 函数：`{sig}`")
        lines.append(f"- 源码：`{src}`" if src else '- 源码：未定位')
        lines.append(f"- 用法：{desc}")
        lines.append(f"- 示例：`{ex}`")
        lines.append(f"- 注意：{pit}")
        if doc_row:
            lines.append(f"- 历史文档：`collect_doc_id={doc_row['collect_doc_id']}`，标题 `{doc_row['title']}`")
        lines.append('')
    (OUT / 'filter_registry.md').write_text('\n'.join(lines), encoding='utf-8')


def gen_filter_category_docs(filters):
    keys = [k for k, _ in filters]
    for cat, cat_keys in CATEGORY.items():
        lines = [f"# {CATEGORY_TITLE[cat]} Filters", '']
        for key in cat_keys:
            if key not in keys:
                continue
            desc, ex, pit = FILTER_HELP.get(key, ('见源码实现', f'{{{{{key}}}}}', '按源码确认'))
            lines.append(f"## `{key}`")
            lines.append(f"- 用法：{desc}")
            lines.append(f"- 示例：`{ex}`")
            lines.append(f"- 注意：{pit}")
            lines.append('')
        (OUT / 'filters' / f'{cat}.md').write_text('\n'.join(lines), encoding='utf-8')


def find_doc_for_module(module_key: str, docs):
    exact = [d for d in docs if d['title'] == module_key]
    if exact:
        return exact[0], 'exact_title'
    fuzzy = [d for d in docs if module_key in (d['title'] or '') or module_key in (d['code'] or '')]
    if fuzzy:
        return fuzzy[0], 'fuzzy'
    return None, 'none'


def gen_module_docs(router, docs):
    module_handlers = router.get('module_handler', [])
    data_handlers = router.get('data_handler', [])

    for section, items in [('module_handler', module_handlers), ('data_handler', data_handlers)]:
        for it in items:
            key = it.get('key', '')
            name = it.get('name', '')
            typ = it.get('type', '')
            path = it.get('path', '')
            row, mtype = find_doc_for_module(key, docs)
            detail = ''
            if row:
                counts = fetch_doc_detail_counts(row['collect_doc_id'])
                detail = (
                    f"- 映射文档：`{row['title']}` (`{row['collect_doc_id']}`)\\n"
                    f"- 映射方式：`{mtype}`\\n"
                    f"- 文档明细：important={counts['collect_doc_important']} params={counts['collect_doc_params']} demo={counts['collect_doc_demo']} result={counts['collect_doc_result']}"
                )
            else:
                detail = '- 映射文档：未命中（建议在 collect_doc 补充模块说明）'

            lifecycle = (
                '在 service 定义中作为 `module` 直接执行（module_handler）。' if section == 'module_handler'
                else '在 `handler_params`/`result_handler` 中作为步骤执行（data_handler）。'
            )

            text = f"""# `{key}`

- 名称：{name}
- 类型：{typ}
- 注册路径：`{path}`
- 生命周期：{lifecycle}

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
{detail}

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
"""
            out = OUT / 'modules' / section / f'{key}.md'
            out.write_text(text, encoding='utf-8')


def gen_registry_docs(router):
    lines = ['# 模块注册总表', '', '来源：`collect/service_router.yml`', '']
    for sec in ['module_handler', 'data_handler']:
        items = router.get(sec, [])
        lines.append(f"## {sec}")
        lines.append('| key | name | type | path |')
        lines.append('|---|---|---|---|')
        for it in items:
            lines.append(f"| `{it.get('key','')}` | {it.get('name','')} | {it.get('type','')} | `{it.get('path','')}` |")
        lines.append('')
    (OUT / 'module_registry.md').write_text('\n'.join(lines), encoding='utf-8')


def gen_custom_filter_doc(filters):
    lines = [
        '# 模板自定义 Filter 指南',
        '',
        'Filter 在 `template`、`if_template` 中调用，例如：',
        '- `template: "{{uuid}}"`',
        '- `if_template: "{{must .agency_id}}"`',
        '- `template: "{{unix_time -1 `day`}}*1000"`',
        '',
        '## 生命周期位置',
        '- `params`：初始化默认值和计算字段。',
        '- `handler_params`：步骤执行前后数据加工。',
        '- `result_handler`：返回结果整形。',
        '- `filter`/`if_template`：条件分支、增量过滤。',
        '',
        '## 可用 Filter 清单',
        f"共 `{len(filters)}` 个，详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)。",
        '',
        '## 常见坑',
        '- `unix_time` 是秒级，毫秒请手动 `*1000`。',
        '- `first_item` 对空数组无保护，先 `must` 再取值。',
        '- `join` 期望字符串数组，混合类型可能报错。',
        '- 组合键匹配时注意 `field/right_field` 方向不要写反。',
    ]
    (OUT / 'custom_filter_template.md').write_text('\n'.join(lines), encoding='utf-8')


def gen_source_mapping(router, docs):
    lines = ['# 模块与文档映射报告', '', '来源：`service_router.yml` + `price.db.collect_doc*`', '']
    for sec in ['module_handler', 'data_handler']:
        lines.append(f'## {sec}')
        lines.append('| key | mapped | collect_doc_id | title | mode |')
        lines.append('|---|---|---|---|---|')
        for it in router.get(sec, []):
            row, mode = find_doc_for_module(it.get('key', ''), docs)
            if row:
                lines.append(f"| `{it.get('key','')}` | yes | `{row['collect_doc_id']}` | {row['title']} | {mode} |")
            else:
                lines.append(f"| `{it.get('key','')}` | no | - | - | {mode} |")
        lines.append('')
    (OUT / 'source_mapping.md').write_text('\n'.join(lines), encoding='utf-8')


def gen_readme(router, filters):
    mh = len(router.get('module_handler', []))
    dh = len(router.get('data_handler', []))
    lines = [
        '# Lowcode 文档总览',
        '',
        '- 模块处理器：`%d`' % mh,
        '- 数据处理器：`%d`' % dh,
        '- 模板 Filter：`%d`' % len(filters),
        '',
        '## 索引',
        '- [module_registry.md](/data/project/auto-check/docs/lowcode/module_registry.md)',
        '- [custom_filter_template.md](/data/project/auto-check/docs/lowcode/custom_filter_template.md)',
        '- [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)',
        '- [source_mapping.md](/data/project/auto-check/docs/lowcode/source_mapping.md)',
        '- filters 分类：',
        '  - [identity_and_id.md](/data/project/auto-check/docs/lowcode/filters/identity_and_id.md)',
        '  - [time_and_date.md](/data/project/auto-check/docs/lowcode/filters/time_and_date.md)',
        '  - [string_and_text.md](/data/project/auto-check/docs/lowcode/filters/string_and_text.md)',
        '  - [array_and_object.md](/data/project/auto-check/docs/lowcode/filters/array_and_object.md)',
        '  - [math_and_cast.md](/data/project/auto-check/docs/lowcode/filters/math_and_cast.md)',
        '  - [runtime_and_guard.md](/data/project/auto-check/docs/lowcode/filters/runtime_and_guard.md)',
    ]
    (OUT / 'README.md').write_text('\n'.join(lines), encoding='utf-8')


def main():
    router = read_yaml(ROUTER)
    filters = parse_filters_register(FILTER_REGISTER)
    docs = fetch_doc_rows()

    gen_registry_docs(router)
    gen_filter_registry(filters, docs)
    gen_filter_category_docs(filters)
    gen_custom_filter_doc(filters)
    gen_module_docs(router, docs)
    gen_source_mapping(router, docs)
    gen_readme(router, filters)

    print('generated docs under', OUT)


if __name__ == '__main__':
    main()
