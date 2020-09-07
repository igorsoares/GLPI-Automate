# GLPI-Automate
Automation script to installation of GLPI.

# What he does?

* Install / Download GLPI 9.5.1;
* Download all needed packets (PHP,APACHE, MARIADB...);
* Configure database (MariaDB10) and users.
  * Default user-access : glpi(username) / glpi(password)
  
  
# Screenshot

## Running-state

![First-screenshot](https://user-images.githubusercontent.com/64047018/92344881-ff2ea480-f09d-11ea-80f2-918abe06cb48.png)

## Downloading

### To download, execute this:

`` git clone https://github.com/igorsoares/GLPI-Automate && chmod +x GLPI-Automate/glpi-automate.sh && sudo ./GLPI-Automate/glpi-automate.sh ``

* PS : **RUN AS SUPER USER**

## First-step installation GLPI

1. Access local apache (http://localhost/glpi)

![1](https://user-images.githubusercontent.com/64047018/92387421-dd5c0e80-f0eb-11ea-9ef0-503f521b38bb.png)

2. Accept terms

![2](https://user-images.githubusercontent.com/64047018/92387442-e8af3a00-f0eb-11ea-85f8-4a57addd0a85.png)

3. Click "Install"

![3](https://user-images.githubusercontent.com/64047018/92387458-f238a200-f0eb-11ea-9071-323d7bb55e5b.png)

4. "Continue"

![4](https://user-images.githubusercontent.com/64047018/92387478-fcf33700-f0eb-11ea-8950-b271ade26c0a.png)

5. Fill all components (ServerIP, username and password) and click "Continue".

> Username: glpi  Passwowrd: glpi

![5](https://user-images.githubusercontent.com/64047018/92387492-02508180-f0ec-11ea-82ae-34251e259e14.png)

6. Select database "glpi" and click "Continue"

![6](https://user-images.githubusercontent.com/64047018/92387763-83a81400-f0ec-11ea-9b1f-c26b5fa0c632.png)

7. Wait..

![7](https://user-images.githubusercontent.com/64047018/92387813-96bae400-f0ec-11ea-94a6-0c29fa55d104.png)

8. Accept (Or not)

![8](https://user-images.githubusercontent.com/64047018/92387840-a33f3c80-f0ec-11ea-8388-51d16277cabe.png)

9. Almost there.. 

![9](https://user-images.githubusercontent.com/64047018/92387862-a9cdb400-f0ec-11ea-895f-0a4bb4006fd6.png)

10. And here we are !

![10](https://user-images.githubusercontent.com/64047018/92387895-b94cfd00-f0ec-11ea-9ae8-97acf7bb055e.png)




