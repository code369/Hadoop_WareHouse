###一、导入
1.从Oracle
#全量导入(不需要提前建表，自动生成表，后续增量会覆盖）
#销售主表B2B_SALE_ORDER
sqoop import --hive-import \
--connect jdbc:oracle:thin:@172.31.13.27:1521/xtpdg \
--username=dmuser \
--password=kWV8xudDIic= \
--table MPLATFORM.B2B_SALE_ORDER \
--hive-database test_ods \
--hive-table ods_B2B_SALE_ORDER \
--hive-overwrite -m 1 \
--compression-codec org.apache.hadoop.io.compress.SnappyCodec \
--null-string '\\N' \
--null-non-string '\\N';

#query方式全量导入
#产品基础表
sqoop import --hive-import \
--connect jdbc:oracle:thin:@172.31.13.27:1521/xtpdg \
--username=dmuser \
--password=kWV8xudDIic= \
--direct \
--query "select  * from MPLATFORM.BASE_PRODUCT_INFO where \$CONDITIONS" \
--target-dir /test01/ods_tmp/ods_BASE_PRODUCT_INFO/ \
--hive-database test_ods \
--hive-table ods_BASE_PRODUCT_INFO \
--hive-overwrite \
--compression-codec org.apache.hadoop.io.compress.SnappyCodec \
--null-string '\\N' \
--null-non-string '\\N' \
-m 1 ;



2.从MySQL
#1、全量导入 合同表lnk_agreement：
sqoop import \
--connect jdbc:mysql://172.30.2.217:3306/linkcrm \
--username biuser \
--password qy@linkcrmAbc \
--table lnk_agreement \
--fields-terminated-by "," \
--lines-terminated-by "\n" \
--hive-import \
--hive-database test_ods \
--hive-table ods_lnk_agreement \
--hive-overwrite;

3.从sqlsever
#全量导入方式
#AD人员表
sqoop import --driver com.microsoft.sqlserver.jdbc.SQLServerDriver \
-connect "jdbc:sqlserver://172.30.3.93:1433; username=dds_user;password=dds_user;database=Ultimus2017Biz;selectMethod=cursor" \
--table ORG_USER --hive-table test_ods.ods_ORG_USER \
--hive-import -m 1 \
--hive-overwrite \
--input-null-string '\\N' \
--input-null-non-string '\\N' \
--null-string '\\N' \
--null-non-string '\\N'  \
--hive-drop-import-delims \
--fields-terminated-by '\0001';

#query方式导入
#场景：个别字段过长容易失败可以选择query导入，指定条件和字段）
#流程实例表（xml格式的列不支持）
sqoop import --driver com.microsoft.sqlserver.jdbc.SQLServerDriver \
--connect "jdbc:sqlserver://172.30.3.93:1433; username=dds_user;password=dds_user;database=Ultimus2017Server;selectMethod=cursor" \
--query 'select PROCESSNAME,INCIDENT,SUMMARY,STARTTIME,ENDTIME,STATUS,INITIATOR,TIMELIMIT from INCIDENTS WHERE $CONDITIONS' \
--target-dir /test01/ods_tmp \
--hive-table test_ods.ods_INCIDENTS --hive-import -m 1 --hive-overwrite \
--input-null-string '\\N' --input-null-non-string '\\N' \
--null-string '\\N' \
--null-non-string '\\N'  \
--hive-drop-import-delims --fields-terminated-by '\0001' ;

#优化，引入--delete-target-dir参数代表指定目录如果存在先删除目录再重新创建
#ods_INCIDENTS流程实例表
sqoop import --driver com.microsoft.sqlserver.jdbc.SQLServerDriver \
--connect "jdbc:sqlserver://172.31.12.41:1433; username=dds_user;password=dds_user;database=Ultimus2017Server;selectMethod=cursor" \
--query 'select PROCESSNAME,INCIDENT,SUMMARY,STARTTIME,ENDTIME,STATUS,INITIATOR,TIMELIMIT from INCIDENTS WHERE $CONDITIONS' \
--target-dir /test01/ods_tmp \
--delete-target-dir  \
--hive-table test01.ods_INCIDENTS --hive-import -m 1 --hive-overwrite \
--input-null-string '\\N' --input-null-non-string '\\N' \
--null-string '\\N' \
--null-non-string '\\N'  \
--hive-drop-import-delims --fields-terminated-by '\0001' ;

### 二、导出
1.MySQL
#注意一定要先在mysql中建好表结构，包括字段和字段类型，否则会导入失败
#dm层(表名为dm_numcheck)导出到mysql(表名为mysql_numcheck)
sqoop export \
--connect jdbc:mysql://172.30.3.78:3309/Test?useSSL=false \
--username ywfxuat \
--password ywfxuat123 \
--table mysql_numcheck \
--export-dir /data/user/hive/warehouse/test_dm.db/dm_numcheck/000000_0 \
--input-fields-terminated-by '\001' \
--update-key id \
--update-mode allowinsert \
--input-null-string '\\N' \
--input-null-non-string '\\N' \
--fields-terminated-by '\t';



2.Oracle（备用，待完善）