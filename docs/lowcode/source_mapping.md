# 模块与文档映射报告

来源：`service_router.yml` + `price.db.collect_doc*`

## module_handler
| key | mapped | collect_doc_id | title | mode |
|---|---|---|---|---|
| `sql` | yes | `ccc4f5b6-2e98-4692-9e6b-333c1ab404e0` | sql | exact_title |
| `model_save` | yes | `9b4fbf55-b221-4b05-86f1-2e78132ee552` | model_save | exact_title |
| `model_update` | yes | `0722aa5a-78e6-4a29-818c-ba33843bdf81` | model_update | exact_title |
| `model_delete` | yes | `8ec4053f-1a54-4f78-9de6-31db6995692e` | model_delete | exact_title |
| `bulk_create` | yes | `894496fd-4201-4b40-95d6-24ecd978b719` | bulk_create | exact_title |
| `bulk_upsert` | yes | `803b90d9-c58c-4113-b4c0-58782e03142c` | bulk_upsert | exact_title |
| `empty` | yes | `d25ddb2a-2c4e-4d3f-83c3-50ddc4215de8` | empty | exact_title |
| `bulk_service` | yes | `eb55515c-df08-4ac5-a4e8-3d811b834e54` | bulk_service | exact_title |
| `http` | yes | `c00a6f14-98c1-4308-8017-cf35ae300de4` | http | exact_title |
| `ldap` | yes | `9215873e-d44d-4a8f-b243-f2c45b1833e5` | ldap | exact_title |
| `service_flow` | yes | `f4a4f3ed-8051-4754-92e2-2a5883fd9f98` | service_flow | exact_title |
| `ssh` | no | - | - | none |
| `read_file` | no | - | - | none |

## data_handler
| key | mapped | collect_doc_id | title | mode |
|---|---|---|---|---|
| `update_field` | yes | `ede82dd3-1b4f-4097-9260-c2d9c7acdf21` | update_field | exact_title |
| `prop_arr` | yes | `f272ba24-4c3e-4072-be07-abae59c93907` | prop_arr | exact_title |
| `check_field` | yes | `f7350f20-20fb-47f4-8b19-511c8b5b38a9` | check_field | exact_title |
| `update_array` | yes | `849062cb-1f83-454e-b81d-3d7754f9ac4a` | update_array | exact_title |
| `update_array_from_array` | yes | `c0f45c6a-688e-46b7-ba0f-ac544f27c3b5` | update_array_from_array | exact_title |
| `array_zip` | no | - | - | none |
| `service2field` | yes | `45d1d393-6758-4c37-8ba9-108493f67b8e` | service2field | exact_title |
| `arr2obj` | yes | `ce02406f-f729-47da-a119-35ed01c6c1c3` | arr2obj | exact_title |
| `arr2dict` | yes | `67193cc3-900e-4c27-a3f6-75ee2dba5688` | arr2dict | exact_title |
| `filter_arr` | yes | `74973d56-9773-432f-b1d5-3b68ad40998d` | filter_arr | exact_title |
| `file_move` | no | - | - | none |
| `param2result` | yes | `1ba89c00-fd10-4756-9414-070bf51505d7` | param2result | exact_title |
| `params2result` | yes | `e32693d9-a954-48ac-a1bb-097a0684c8b3` | params2result | exact_title |
| `result2params` | yes | `5881b6e1-8217-475f-9b05-4bc20ffdae8e` | result2params | exact_title |
| `result2map` | yes | `b9eab01d-7236-4d15-9053-0f193a3d2ffb` | result2map | exact_title |
| `count2map` | yes | `25d3fdcb-162a-4ef2-a4af-3b7edcc6e42a` | count2map | exact_title |
| `session_add` | yes | `01044aa5-6f65-4b59-a4a9-ae7a0191be4c` | session_add | exact_title |
| `session_remove` | yes | `293dffa7-1a0b-4e72-8bd7-0f2a44758495` | session_remove | exact_title |
| `session_get` | yes | `5b86a474-2af6-4e82-8d25-3635645bc315` | session_get | exact_title |
| `data2excel` | yes | `d4ee2257-8a51-40bf-8d48-4b5469858e21` | data2excel | exact_title |
| `excel2data` | yes | `28a1f850-9e5f-4368-9230-220abf98af15` | excel2data | exact_title |
| `file2str` | no | - | - | none |
| `file2json` | no | - | - | none |
| `str2file` | no | - | - | none |
| `str2img` | no | - | - | none |
| `str2json` | no | - | - | none |
| `ignore_data` | yes | `0b3ebb5e-8ce6-4ebc-ae92-da6b0dfe13a2` | ignore_data | exact_title |
| `file2result` | yes | `36248998-48ee-41db-a0f4-2010b056b2a3` | file2result | exact_title |
| `files2result` | no | - | - | none |
| `file2datajson` | yes | `bd6431c8-caf3-4ae9-96af-03cce615204b` | file2datajson | exact_title |
| `field2array` | yes | `eee7f650-4583-4bf6-b770-ce853eba8c54` | field2array | exact_title |
| `arr2arrayObj` | yes | `79d0939d-16f6-4c8d-b611-5a55409162ad` | arr2arrayObj | exact_title |
| `get_modify_data` | yes | `b7a26057-abd7-45a0-9101-63e01af6ed4c` | get_modify_data | exact_title |
| `group_by` | yes | `31e7d7f9-c87e-4558-bd76-f673d34e1c84` | group_by | exact_title |
| `order_by` | no | - | - | none |
| `agg` | no | - | - | none |
| `combine_array` | yes | `70bbd0a8-5e8a-4083-9986-e8c0c320ebe0` | combine_array | exact_title |
| `handler_cache` | yes | `77e10054-791e-4889-a5c8-1fc2b9a6e514` | handler_cache | exact_title |
| `prevent_duplication` | yes | `e3d5dce4-c758-41cc-9ffd-578ca39836e3` | prevent_duplication | exact_title |
| `to_tree` | yes | `6e77eedf-b68b-43e3-9510-1a5c60b3073a` | to_tree | exact_title |
| `to_list` | yes | `efe3adb4-5447-4999-8fbb-964af43eec6c` | to_list | exact_title |
| `update_order` | yes | `6779d656-023d-43e0-802d-e321a1fe9650` | update_order | exact_title |
| `analysis_ip` | no | - | - | none |
| `shell` | no | - | - | none |
| `sftp` | no | - | - | none |
| `shell_term` | no | - | - | none |
| `param_key2arr` | no | - | - | none |
| `rename_field` | no | - | - | none |
| `multi_arr` | no | - | - | none |
| `handler_password` | no | - | - | none |
| `value_transfer` | no | - | - | none |
| `analysis_attendance` | no | - | - | none |
| `to_local_file` | no | - | - | none |
| `gen_sport_level` | no | - | - | none |
| `xml2json` | no | - | - | none |
| `schema_transfer` | no | - | - | none |
| `gen_doc_project` | no | - | - | none |
| `gen_sign` | no | - | - | none |
| `gen_doc` | no | - | - | none |
| `render_doc` | no | - | - | none |
| `extract_bid` | no | - | - | none |
| `fix_json` | no | - | - | none |
| `handler_tree_level_order` | no | - | - | none |
| `client_ip` | no | - | - | none |
