# Access Your ADG Workshop Environment

## Introduction
In this lab, you will learn how to access your ADG workshop environment. You will be assigned an environment to this workshop. It's include:

- A VM which already have installed a database 19c to simulate the on-premise database. You can connect to the VM instance with a ssh tools. The hostname and public ip address will be provide by the instructor.
- A Database Cloud Service which act as the standby database in the workshop. You will be assigned an OCI account to log into the Oracle Cloud console to access and manage your DBCS.

### Prerequisites

This lab assumes you have:
- A Cloud account including: tenant name, username, password.

- The Region and Compartment where the DBCS created.

- A DBCS which assigned to you to act the standby database.

- SSH Keys download from [here - labkey.zip](https://github.com/minqiaowang/hybrid-adg-apac/raw/master/ssh-keys/labkey.zip). Unzip the files to your own laptop.

- A compute VM instance hostname and IP address which assigned to you to act as the on-premise database.

  

## **STEP 1**: Connect to your Compute instance

There are multiple ways to connect to your cloud instance.  Choose the way to connect to your cloud instance using the SSH Key you downloaded and unzipped. 

- MAC or Windows CYCGWIN Emulator

- Windows Using Putty
  
  
### MAC or Windows CYGWIN Emulator
1. Open up a terminal (MAC) or cygwin emulator as the opc user.  Enter yes when prompted.

    ````
    chmod 600 labkey
    ssh -i labkey opc@<Your Compute Instance Public IP Address>
    ````
    ![](./images/ssh-first-time.png " ")

    

4.  After successfully logging in, you can continue to do your lab.

### Windows using Putty

1.  Open up putty and enter the public ip address.

2.  Enter a name for the session and click **Save**.

    ![](./images/putty-setup.png " ")

3. Click **Connection** > **Data** in the left navigation pane and set the Auto-login username to **opc**.

4. Click **Connection** > **SSH** > **Auth** in the left navigation pane and configure the SSH private key to use by clicking Browse under Private key file for authentication.

5. Navigate to the location where you saved your SSH private key file, select the file like labkey.ppk, and click Open.  NOTE:  You cannot connect while on VPN or in the Oracle office on clear-corporate (choose clear-internet).

    ![](./images/putty-auth.png " ")

6. The file path for the SSH private key file now displays in the Private key file for authentication field.

7. Click Session in the left navigation pane, then click Save in the Load, save or delete a stored session STEP.

8. Click Open to begin your session with the instance.

## **STEP 2**: Browse the DBCS on OCI

You can browse the Database Cloud Service that assigned to you.
1.  Connect to the Oracle Cloud Infrastructure Using the URL that instructor provided, like: `https://console.**-***-1.oraclecloud.com`. Enter the tenant name, username and password. 
    
    ![](images/image-20200808121527712.png)
    
2.  After signed into the OCI console, Open the navigation menu. Under **Database**, click **Bare Metal, VM, and Exadata**.

    ![](images/image-20200808122124697.png)

3. Make sure you are in the correct region and choose the right compartment, Click the link of the DB system which assigned to you.

    ![](images/image-20200808122618014.png)

4. In the **DB system Details** page, click the **Nodes** under the **Resources**, Write down the hostname, domain name and public ip address of the DB host.

    ![](images/image-20200808122936413.png)

5. Connect to the DB host with command line or putty as the Step 1.

6. Now you can move to the next lab.
