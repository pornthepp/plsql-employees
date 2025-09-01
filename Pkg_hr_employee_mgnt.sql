CREATE OR REPLACE PACKAGE pkg_hr_employee_mgnt AS
    -- Show employee information by ID
    PROCEDURE show_employee_info (p_emp_id  employees_copy.employee_id%TYPE := NULL);

    -- Insert a new employee
    PROCEDURE insert_new_emp (p_first_name employees_copy.FIRST_NAME%TYPE,
                                p_last_name employees_copy.LAST_NAME%TYPE,
                                p_email employees_copy.EMAIL%TYPE,
                                p_phone employees_copy.PHONE_NUMBER%TYPE,
                                p_hire_date employees_copy.HIRE_DATE%TYPE,
                                p_job_id employees_copy.JOB_ID%TYPE,
                                p_salary employees_copy.SALARY%TYPE,
                                p_com employees_copy.COMMISSION_PCT%TYPE := NULL,
                                p_mng_id employees_copy.MANAGER_ID%TYPE,
                                p_dept_id employees_copy.DEPARTMENT_ID%TYPE);   

    -- Delete an employee
    PROCEDURE del_emp (p_emp_id employees_copy.employee_id%TYPE);

    -- Increase employee salary by percentage
    PROCEDURE incs_salary(p_emp_id employees_copy.employee_id%TYPE, p_percent NUMBER);

    -- Calculate bonus from salary
    FUNCTION cal_bonus(p_emp_id employees_copy.employee_id%TYPE, p_rate NUMBER) RETURN NUMBER;

    -- Show employee names in a department
    PROCEDURE show_depart_emp (p_dept_id employees_copy.department_id%TYPE);

    -- Get number of employees in a department
    FUNCTION get_empindept(p_dept_id employees_copy.department_id%TYPE) RETURN NUMBER;

    -- Show employee with the highest salary in a department
    PROCEDURE show_emp_highest_sal_by_dept (p_dept employees_copy.department_id%TYPE);

    -- Update employee's department
    PROCEDURE update_dept(p_emp_id employees_copy.employee_id%TYPE, p_dept_id employees_copy.department_id%TYPE);

    -- Calculate total annual income (+ bonus)
    FUNCTION total_sal (p_emp_id employees_copy.employee_id%TYPE, p_bonus_rate NUMBER) RETURN NUMBER;

    -- List employees with salaries above average
    PROCEDURE list_emp_above_avg_salary(p_dept_id employees_copy.department_id%TYPE := NULL); 

    -- List employees by department
    PROCEDURE list_emp_by_dept(p_dept_id NUMBER);

    -- Adjust salary if it is less than 3000 (set to 3000)
    PROCEDURE adjust_min_salary (p_min_salary employees_copy.salary%TYPE);
END pkg_hr_employee_mgnt;
