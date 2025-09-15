create or replace PACKAGE BODY pkg_hr_employee_mgnt AS
    -- Show employee information by ID
    PROCEDURE show_employee_info (p_emp_id  employees_copy.employee_id%TYPE := null)IS
        v_emp_id NUMBER;
        v_first_name VARCHAR2(20);
        v_last_name VARCHAR2(20);
        v_hire_date DATE;
        v_job_id VARCHAR2(20);
        v_salary NUMBER;
    BEGIN
        SELECT employee_id,
            FIRST_NAME,
            LAST_NAME,
            HIRE_DATE,
            JOB_ID,
            SALARY
        INTO v_emp_id,
            v_first_name,
            v_last_name,
            v_hire_date,
            v_job_id,
            v_salary
        FROM employees_copy
        WHERE employee_id = p_emp_id;
        dbms_output.put_line('id: '||v_emp_id||' name: '||v_first_name||' '||v_last_name||
                             ' hireDate: '||v_hire_date||' jobID: '||v_job_id||' salary : '||v_salary);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('no data from id : '||p_emp_id);
    END show_employee_info;
    
    -- Insert a new employee
    PROCEDURE insert_new_emp (p_first_name employees_copy.FIRST_NAME%TYPE,
                                p_last_name employees_copy.LAST_NAME%TYPE,p_email employees_copy.EMAIL%TYPE,
                                p_phone employees_copy.PHONE_NUMBER%TYPE,p_hire_date employees_copy.HIRE_DATE%TYPE,
                                p_job_id employees_copy.JOB_ID%TYPE,p_salary employees_copy.SALARY%TYPE,
                                p_com employees_copy.COMMISSION_PCT%TYPE := null,
                                p_mng_id employees_copy.MANAGER_ID%TYPE,p_dept_id employees_copy.DEPARTMENT_ID%TYPE)IS
    BEGIN
        --check imput
        IF p_first_name IS NULL OR p_last_name IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010,'first/last name is required.');--ชื่อจะต้องไม่เว้นว่าง
        END IF;
        IF p_email IS NULL OR p_phone IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010,'email/phone number is required.');--emailและเบอร์โทรต้องไม่เว้นว่าง
        END IF;
        IF  p_hire_date IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20010,'hire date is required.');--hire_date ต้องไมเว้นว่าง
        END IF;
        IF  p_job_id IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20010,'job id is required.');
        END IF;
        IF  p_mng_id IS NULL OR p_dept_id  IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20010,'manager id/department id is required.');
        END IF;
        
        
        INSERT INTO employees_copy (employee_id,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,salary,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID)
        VALUES (EMP_ID_SEQ.nextval,p_first_name,p_last_name,p_email,p_phone,p_hire_date,p_job_id,p_salary,p_com,p_mng_id,p_dept_id);
    END insert_new_emp;
    
    -- Delete an employee
    PROCEDURE del_emp(p_emp_id employees_copy.employee_id%TYPE) IS
    BEGIN
        DELETE FROM employees_copy WHERE employee_id = p_emp_id;
         
         -- check del row
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'ไม่พบพนักงานรหัส ' || p_emp_id);
        END IF;
    END del_emp;
    
    -- Increase employee salary by percentage

    PROCEDURE incs_salary (p_emp_id employees_copy.employee_id%TYPE,p_percent NUMBER)IS
        v_old_salary employees_copy.salary%TYPE;
        v_new_salary v_old_salary%TYPE;
    BEGIN
        SELECT salary INTO v_old_salary FROM employees_copy
        WHERE employee_id = p_emp_id;
        --calculate for new salary
        v_new_salary := ((p_percent*v_old_salary)/100)+v_old_salary;
        UPDATE employees_copy SET salary = v_new_salary
        WHERE employee_id = p_emp_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'no found employeee id '||p_emp_id);
    END incs_salary;
    
    -- Calculate bonus from salary
    FUNCTION cal_bonus(p_emp_id employees_copy.employee_id%TYPE,p_rate NUMBER) RETURN NUMBER IS
        v_salary employees_copy.salary%TYPE;
        v_bonus v_salary%TYPE;
    BEGIN
        SELECT salary INTO v_salary FROM employees_copy where employee_id = p_emp_id;
        v_bonus := v_salary*p_rate;
        RETURN v_bonus;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'no found employeee id '||p_emp_id);
    END cal_bonus;
    
    -- Show employee names in a department

    PROCEDURE show_depart_emp (p_dept_id employees_copy.department_id%TYPE) IS

        CURSOR cur_depart_emp IS --ursor
            SELECT employee_id,first_name,last_name
            FROM employees_copy WHERE department_id = p_dept_id;
            
        v_emp_id employees_copy.employee_id%TYPE;
        v_first_name employees_copy.first_name%TYPE;
        v_last_name employees_copy.last_name%TYPE;
        v_counter NUMBER:= 0; --check cursor found data
    BEGIN
        OPEN cur_depart_emp;
        LOOP 
            FETCH cur_depart_emp INTO v_emp_id,v_first_name,v_last_name;
            EXIT WHEN cur_depart_emp%NOTFOUND;
            v_counter :=v_counter+1;
            dbms_output.put_line('id : '||v_emp_id||' name: '||v_first_name||' '||v_last_name);
        END LOOP;
        IF v_counter = 0 THEN --if cursor no data then dbms 
                dbms_output.put_line('no data in department id : '||p_dept_id);
        END IF;
        CLOSE cur_depart_emp;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'error '||SQLERRM);
    END show_depart_emp;
    
    -- Get number of employees in a department
    FUNCTION get_empindept(p_dept_id employees_copy.department_id%TYPE) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM employees_copy WHERE department_id= p_dept_id;
        RETURN v_count;
    END get_empindept;
    
    -- Show employee with the highest salary in a department
    PROCEDURE show_emp_highest_sal_by_dept (p_dept employees_copy.department_id%TYPE) IS
        CURSOR cur_highest_sal IS --cursor keep hightest salary
            select employee_id,first_name,last_name,department_id,salary from employees_copy  
            where department_id = p_dept AND salary =(
            select max(salary) from employees_copy where department_id=p_dept);--เพิ่มเงือ่นไข ว่าต้องอยู่ในแผนกxx
    BEGIN
        FOR emp_rec in cur_highest_sal LOOP
        dbms_output.put_line('id: '||emp_rec.employee_id
                        ||' name: '||emp_rec.first_name
                        ||' '||emp_rec.last_name
                        ||' departmentID: '||emp_rec.department_id
                        ||' salary: '||emp_rec.salary);
        END LOOP;
    END show_emp_highest_sal_by_dept;
    
    -- Update employee's department
    PROCEDURE update_dept(p_emp_id employees_copy.employee_id%TYPE,p_dept_id employees_copy.department_id%TYPE )IS
        v_count_emp NUMBER;
        v_count_dept NUMBER;
    BEGIN
        SELECT count(*) INTO v_count_emp FROM employees_copy WHERE employee_id=p_emp_id; --เช็คว่า emp_id มีออยู่จริง
        IF v_count_emp = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'no data found please check employeeID');
        END IF;
        
        SELECT count(*) INTO v_count_dept FROM departments WHERE department_id=p_dept_id; --เช็คว่า department_id มีอยู่จริง
        IF v_count_dept = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'no data found please check departmentID');
        END IF;
        
        UPDATE employees_copy SET department_id = p_dept_id WHERE employee_id=p_emp_id;
    END update_dept;
    
    -- Calculate total annual income (+ bonus)
    FUNCTION total_sal (p_emp_id employees_copy.employee_id%TYPE,p_bonus_rate NUMBER)RETURN NUMBER IS
        v_salary employees_copy.salary%TYPE;
        v_total NUMBER;
    BEGIN
        SELECT salary INTO v_salary FROM employees_copy
        WHERE employee_id = p_emp_id;
        
        v_total := (v_salary*12) + cal_bonus(p_emp_id,p_bonus_rate);--ใช้ fn cal_bonus เพื่อลดขั้นตอนการคำนวนโบนัสซ้ำๆ
        RETURN v_total;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20001,'no data found please check employeeID');
    END total_sal;
    
    -- List employees with salaries above average
    PROCEDURE list_emp_above_avg_salary (p_dept_id employees_copy.department_id%TYPE:= null)  IS --ถ้าระบุแผนก จะให้ใช้ค่าเฉลี่ยแผนกแทน
        CURSOR cur_get_emp_sal IS
            SELECT employee_id,first_name,last_name,salary FROM employees_copy
            WHERE department_id = NVL(p_dept_id,department_id) AND salary > (SELECT AVG(salary)FROM employees_copy WHERE department_id = NVL(p_dept_id,department_id));
    BEGIN
        IF p_dept_id IS NULL THEN
            dbms_output.put_line('Average company salary ');
        ELSE 
            dbms_output.put_line('Average department salary by departmentID '||p_dept_id);
        END IF;
        
        FOR i IN cur_get_emp_sal LOOP
                dbms_output.put_line('ID: '||i.employee_id||'|'||i.first_name||' '||i.last_name||'|'||' salary: '||i.salary);
        END LOOP;
    END list_emp_above_avg_salary;
    
    -- List employees by department
    PROCEDURE list_emp_by_dept(p_dept_id NUMBER) IS
        CURSOR cur_emp_dept IS
            SELECT employee_id,first_name,last_name FROM employees_copy
            WHERE department_id = p_dept_id;
        v_dept_name departments.department_name%TYPE;
        v_emp_id NUMBER;
        v_firstname VARCHAR2(20);
        v_lastname VARCHAR2(20);
        
    BEGIN
        SELECT department_name INTO v_dept_name FROM departments
        WHERE department_id = p_dept_id;
        dbms_output.put_line('employee in department: '||v_dept_name);
        OPEN cur_emp_dept;
        LOOP 
            FETCH cur_emp_dept INTO v_emp_id,v_firstname,v_lastname;
            EXIT WHEN cur_emp_dept%NOTFOUND;
            dbms_output.put_line('ID: '||v_emp_id||'|'||v_firstname||' '||v_lastname);
        END LOOP;
        CLOSE cur_emp_dept;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Department ID '||p_dept_id||' not found.');
        
    END list_emp_by_dept;
    
    -- Adjust salary if it is less than 3000 (set to 3000)
    PROCEDURE adjust_min_salary (p_min_salary employees_copy.salary%TYPE )IS
        CURSOR cur_min_salary IS
            SELECT e.employee_id,e.salary FROM employees_copy e
            WHERE e.salary <p_min_salary;
        v_salary employees_copy.salary%TYPE ;
        v_emp_id employees_copy.employee_id%TYPE;
        v_check_target employees_copy.salary%TYPE ; --check less than min 
    BEGIN
        --check less than min 
        SELECT COUNT(salary) INTO v_check_target FROM employees_copy WHERE salary < p_min_salary;
        IF v_check_target = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'no data found salary less than min salary');
        ELSE
            OPEN cur_min_salary;
            LOOP 
                FETCH cur_min_salary INTO v_emp_id,v_salary;
                EXIT WHEN cur_min_salary%NOTFOUND;
                UPDATE employees_copy SET salary = p_min_salary WHERE employee_id = v_emp_id;
                dbms_output.put_line('set salary of '||v_emp_id||' to '||p_min_salary);
            END LOOP;
        END IF;
    END adjust_min_salary;
    
    -- Get count employees in depth
    FUNCTION get_count_emp_by_dept(p_dept_id NUMBER) RETURN NUMBER IS
        v_countName NUMBER;
    BEGIN
        SELECT COUNT(FIRST_NAME)INTO v_countName FROM EMPLOYEES_COPY WHERE DEPARTMENT_ID = p_dept_id;
        RETURN v_countName;
    END get_count_emp_by_dept;
    
    -- Get Top salary per dept 
    PROCEDURE get_top_sal_from_dept IS
        CURSOR cur_topsal IS
            SELECT e.DEPARTMENT_ID,e.EMPLOYEE_ID,e.SALARY FROM EMPLOYEES_COPY e
            WHERE e.SALARY = (SELECT MAX(SALARY)FROM EMPLOYEES_COPY WHERE DEPARTMENT_ID= e.DEPARTMENT_ID);
            
        v_dept_id EMPLOYEES_COPY.DEPARTMENT_ID%TYPE;
        v_emp_id EMPLOYEES_COPY.EMPLOYEE_ID%TYPE;
        v_sal  EMPLOYEES_COPY.SALARY%TYPE;
    BEGIN
        OPEN cur_topsal;
        LOOP 
            FETCH cur_topsal INTO v_dept_id,v_emp_id,v_sal;
            EXIT WHEN cur_topsal%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Employee Highest Salary in Department');
            DBMS_OUTPUT.PUT_LINE('department id: '||v_dept_id||' employee id: '||v_emp_id||'salary: '||v_sal);
        END LOOP;
        CLOSE cur_topsal;
    END get_top_sal_from_dept;
    
END pkg_hr_employee_mgnt;
