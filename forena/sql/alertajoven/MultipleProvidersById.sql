-- ACCESS=access content
select  entity_id, field_agency_name_value from bitnami_drupal7.field_data_field_agency_name 
where entity_id in (:values)