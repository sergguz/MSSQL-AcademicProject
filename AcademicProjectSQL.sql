

CREATE OR REPLACE FUNCTION valueInv (p_invid IN NUMBER) RETURN NUMBER AS
v_invid NUMBER := p_invid;
v_result NUMBER;
v_qoh NUMBER;
v_price NUMBER;
BEGIN
	SELECT inv_price, inv_qoh
	INTO v_price, v_qoh
	FROM inventory
	WHERE inv_id = v_invid;

v_result := v_price * v_qoh;
RETURN v_result;
END;
/

CREATE OR REPLACE PROCEDURE finalVal (p_invid IN NUMBER) AS
BEGIN
	DBMS_OUTPUT.PUT_LINE('The value of the inventory number '||p_invid||
						' is '||valueInv(p_invid)||' dollar.');
END;
/
______________________________________________________________________________

CREATE OR REPLACE PROCEDURE countDays (p_oid IN NUMBER) AS
v_oid NUMBER := p_oid;
v_date DATE;
v_days NUMBER;
v_today DATE;
BEGIN
	SELECT o_date
	INTO v_date
	FROM orders
	WHERE o_id = v_oid;

v_today := sysdate;
v_days := TRUNC(v_today - v_date);
DBMS_OUTPUT.PUT_LINE('Order number '||v_oid||' is placed on '||v_date||
						'. It has been '||v_days||' days since.');
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE(' Order does not exist');
END;
/
______________________________________________________________________________


CREATE OR REPLACE PROCEDURE displayItInv AS
BEGIN
	FOR item_index IN (SELECT item_id, item_desc, cat_id FROM item) LOOP
	DBMS_OUTPUT.PUT_LINE('=========================================');
	DBMS_OUTPUT.PUT_LINE('Item id: '||item_index.item_id||
						' Description: '||item_index.item_desc||
						' Category: '||item_index.cat_id);
		FOR inv_index IN (SELECT inv_id, color, inv_size, inv_price FROM inventory
							WHERE item_id = item_index.item_id) LOOP
		DBMS_OUTPUT.PUT_LINE('Inventory id: '||inv_index.inv_id||
							' Color: '||inv_index.color||
							' Size: '||inv_index.inv_size||
							' Price: '||inv_index.inv_price);
		END LOOP;
	END LOOP;
END;
/

______________________________________________________________________________


CREATE TABLE ol_audit (audit_id NUMBER, o_id NUMBER, inv_id NUMBER, ol_quantity NUMBER);

CREATE SEQUENCE ol_seq_audit START WITH 1;

CREATE OR REPLACE TRIGGER ol_audit_trigg
BEFORE UPDATE ON order_line
FOR EACH ROW
DECLARE 
BEGIN
	INSERT INTO ol_audit
	VALUES (ol_seq_audit.NEXTVAL, :OLD.o_id, :OLD.inv_id, :OLD.ol_quantity);
END;
/

UPDATE order_line
SET ol_quantity = 20
WHERE o_id = 1
AND inv_id = 14;

SELECT ol_quantity
FROM order_line
WHERE o_id = 1
AND inv_id = 14;

______________________________________________________________________________

CREATE OR REPLACE PACKAGE exam_last IS 
FUNCTION valueInv (p_invid IN NUMBER) RETURN NUMBER;
PROCEDURE finalVal (p_invid IN NUMBER);
PROCEDURE countDays (p_oid IN NUMBER);
PROCEDURE displayItInv;
END;
/

CREATE OR REPLACE PACKAGE BODY exam_last IS
FUNCTION valueInv (p_invid IN NUMBER) RETURN NUMBER AS
v_invid NUMBER := p_invid;
v_result NUMBER;
v_qoh NUMBER;
v_price NUMBER;
BEGIN
	SELECT inv_price, inv_qoh
	INTO v_price, v_qoh
	FROM inventory
	WHERE inv_id = v_invid;

v_result := v_price * v_qoh;
RETURN v_result;
END valueInv;

PROCEDURE finalVal (p_invid IN NUMBER) AS
BEGIN
	DBMS_OUTPUT.PUT_LINE('The value of the inventory number '||p_invid||
						' is '||valueInv(p_invid)||' dollar.');
END finalVal;

PROCEDURE countDays (p_oid IN NUMBER) AS
v_oid NUMBER := p_oid;
v_date DATE;
v_days NUMBER;
v_today DATE;
BEGIN
	SELECT o_date
	INTO v_date
	FROM orders
	WHERE o_id = v_oid;

v_today := sysdate;
v_days := TRUNC(v_today - v_date);
DBMS_OUTPUT.PUT_LINE('Order number '||v_oid||' is placed on '||v_date||
						'. It has been '||v_days||' days since.');
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE(' Order does not exist');
END countDays;

PROCEDURE displayItInv AS
BEGIN
	FOR item_index IN (SELECT item_id, item_desc, cat_id FROM item) LOOP
	DBMS_OUTPUT.PUT_LINE('=========================================');
	DBMS_OUTPUT.PUT_LINE('Item id: '||item_index.item_id||
						' Description: '||item_index.item_desc||
						' Category: '||item_index.cat_id);
		FOR inv_index IN (SELECT inv_id, color, inv_size, inv_price FROM inventory
							WHERE item_id = item_index.item_id) LOOP
		DBMS_OUTPUT.PUT_LINE('Inventory id: '||inv_index.inv_id||
							' Color: '||inv_index.color||
							' Size: '||inv_index.inv_size||
							' Price: '||inv_index.inv_price);
		END LOOP;
	END LOOP;
END displayItInv;
END;
/

BEGIN
exam_last.countDays(2);
END;
/

BEGIN
exam_last.displayItInv;
END;
/

______________________________________________________________________________

CREATE OR REPLACE PACKAGE exam_last2 IS
	FUNCTION oid_good (p_oid IN NUMBER) RETURN BOOLEAN;
	PROCEDURE up_orders (p_oid NUMBER, p_date DATE);
	PROCEDURE up_orders (p_oid NUMBER, p_methpmt VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY exam_last2 IS
FUNCTION oid_good (p_oid IN NUMBER) RETURN BOOLEAN AS
oidGood BOOLEAN := FALSE;
BEGIN
	FOR oid_index IN (SELECT o_id FROM orders) LOOP
		IF oid_index.o_id = p_oid THEN
			oidGood := TRUE;
		END IF;
	END LOOP;
RETURN oidGood;
END oid_good;

PROCEDURE up_orders(p_oid NUMBER, p_date DATE) AS
BEGIN
	IF oid_good(p_oid) THEN
		UPDATE orders
		SET o_date = p_date
		WHERE o_id = p_oid;
		COMMIT;
	ELSE
		DBMS_OUTPUT.PUT_LINE('The order id does not exist');
	END IF;
END;

PROCEDURE up_orders(p_oid NUMBER, p_methpmt VARCHAR2) AS
BEGIN
	IF oid_good(p_oid) THEN
		UPDATE orders
		SET o_methpmt = p_methpmt
		WHERE o_id = p_oid;
		COMMIT;
	ELSE
		DBMS_OUTPUT.PUT_LINE('The order id does not exist'); 
	END IF;
END;
END;
/

BEGIN
exam_last2.up_orders(2, sysdate);
END;
/