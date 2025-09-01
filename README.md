
## Procedures & Functions

#### Show employee information by emp_id
```sql
  show_employee_info (employeeId);
```
#### Delete an employee by emp_id
```sql
  del_emp (employeeId);
```
#### Increase employee salary by given percentage
```sql
  incs_salary (employeeId,percentage);
```
#### Calculate bonus from salary and given rate
```sql
  cal_bonus (employeeId,bonusRate); //like 0.1
```
#### Show employee names in a department
```sql
  show_depart_emp (departmentId); 
```
#### Get number of employees in a department
```sql
  get_empindept (departmentId); 
```
#### Get number of employees in a department
```sql
  show_emp_highest_sal_by_dept (departmentId); 
```
#### Update employee’s department
```sql
  update_dept (employeeId,departmentId); 
```
#### Calculate total annual income (+bonus)
```sql
  total_sal (employeeId,bonusRate); 
```
#### List employees with salary above average
```sql
  list_emp_above_avg_salary (departmentId); 
```
#### List employees by department
```sql
  list_emp_by_dept (departmentId); 
```
#### Adjust salary: if lower than min Salary
```sql
  adjust_min_salary (minSalary); 
```
