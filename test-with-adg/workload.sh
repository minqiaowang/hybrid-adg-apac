echo ""
echo "  NOTE:"
echo "  To break out of this batch"
echo "  job, please issue CTL-C "
echo ""
echo "...sleeping 5 seconds"
echo ""
sleep 5

  sqlplus -S /nolog << EOF
  connect testuser/testuser@orclpdb;
  drop table sale_orders;
  create table sale_orders(ORDER_ID number, ORDER_DATE varchar2(9), CUSTOMER_ID number);
EOF

c=1
while [ $c -le 1000 ]
do
  sqlplus -S /nolog  << EOF
  connect testuser/testuser@orclpdb;
  insert all
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3035,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
    into sale_orders (ORDER_ID, ORDER_DATE, CUSTOMER_ID) VALUES (3041,'10-MAY-20', 13287)
  select 1 from dual;
  commit;
  select count(*) from sale_orders;
  @scn.sql
EOF
sleep 1
(( c++))
done