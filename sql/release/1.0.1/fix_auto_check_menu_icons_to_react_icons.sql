-- 修正 auto-check 项目 sys_menu 中的旧菜单图标值
-- 仅处理已确认映射的 legacy 值，避免猜测性替换

UPDATE sys_menu
SET icon = CASE icon
    WHEN 'FaHome' THEN 'RiHomeLine'
    WHEN 'FaStoreAlt' THEN 'RiStore2Line'
    WHEN 'FaWarehouse' THEN 'LuWarehouse'
    WHEN 'FaHouseUser' THEN 'LuUserCog'
    WHEN 'FaSitemap' THEN 'PiTreeStructure'
    WHEN 'FaRoute' THEN 'RiRouteLine'
    ELSE icon
END
WHERE belong_project = 'auto-check'
  AND icon IN (
    'FaHome',
    'FaStoreAlt',
    'FaWarehouse',
    'FaHouseUser',
    'FaSitemap',
    'FaRoute'
  );

-- 校验：确认已知 legacy 菜单图标是否已经清理完成
SELECT menu_code, menu_name, icon
FROM sys_menu
WHERE belong_project = 'auto-check'
  AND icon IN (
    'FaHome',
    'FaStoreAlt',
    'FaWarehouse',
    'FaHouseUser',
    'FaSitemap',
    'FaRoute'
  )
ORDER BY order_index, menu_code;

-- 排查：列出当前项目里其余尚未处理的 Fa* 值，供后续人工确认
SELECT DISTINCT icon
FROM sys_menu
WHERE belong_project = 'auto-check'
  AND icon LIKE 'Fa%'
ORDER BY icon;
