module ItemData
  CACHE = AtlanticaOnlineCraftCalculator::Item.read_data_from_yaml_file(
    AtlanticaOnlineCraftCalculator::Item::DEFAULT_DATA_FILE_PATH
  )
end
