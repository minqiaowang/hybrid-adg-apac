# Setup - Primary and Standby Database 19c

## Introduction

In this workshop, you will use the compute instances in the Oracle Cloud to simulate the on-premise primary and standby database. This lab will show you how to setup a Oracle Cloud network (VCN) and the compute instance running a pre-configured Oracle Database 19c install using Oracle Resource Manager and Terraform. You can setup the primary and standby database using the related scripts. The primary and the standby database are in different VCN. You can prepare multiple primary and standby database for students before the workshop.

### Objectives

-   Setup a network and compute instance using the DB19c Marketplace image
-   Use Terraform and Resource Manager to complete the setup

### Lab Prerequisites

This lab assumes you have already completed the following:
- Have Oracle Cloud Account
- Create SSH Keys

Click on the link below to download the Resource Manager zip files you need to build your enviornment.

- [db19c-primary-num.zip](https://github.com/minqiaowang/hybrid-adg-apac/raw/master/setup-labenv/db19c-primary-num.zip) - Packaged terraform primary database instance creation script
- [dbcs-standby-num.zip](https://github.com/minqiaowang/hybrid-adg-apac/raw/master/setup-labenv/dbcs-standby-num.zip) - Packaged terraform standby database cloud service creation script



## Step 1: Prepare the Primary Database

3.  Open up the hamburger menu in the left hand corner. Choose **Resource Manager > Stacks**. Choose the **Compartment** that you want to use, click the  **Create Stack** button. *Note: If you are in a workshop, double check your region to ensure you are on the assigned region.*

    ![](./images/cloud-homepage.png " ")

    ![](./images/resource.png " ")

    

    ![](./images/step1.3-createstackpage.png " ")

4.  Click the **Browse** link and select the primary database setup zip file (db19c-primary-num.zip) that you downloaded. Click **Select** to upload the zip file.

    ![](./images/step1.4-create-stack-orig.png " ")

    Enter the following information. Accept all the defaults and click **Next**.

    - **Name**:  Enter your name of the stack. *(Do not enter any special characters here, including periods, underscores, exclamation etc, it will mess up the configuration and you will get an error during the apply process.)*

    - **Description**:  Same as above

    - **Compartment**:  Accept the default or change to the correct compartment.

5.  Enter the following information and click **Next**. You will be updating Num_Instances and SSH Key.

    ![](images/image-20200622161816355.png " ")

    **SSH Public Key**:  Paste the public key you created in the earlier step. *(Note: If you used the Oracle Cloud Shell to create your key, make sure you paste the pub file in a notepad, remove any hard returns.  The file should be one line or you will not be able to login to your compute instance)*

    **NUM_INSTANCES:** How many instances you want to create for the base on the number of  the students. Default is 1.

6.  Click **Create**.

    ![](./images/step1.6-create-db19c-stack-3.png " ")

7.  Your stack has now been created!  Now to create your environment. *Note: If you get an error about an invalid DNS label, go back to your Display Name, please do not enter ANY special characters or spaces. It will fail.*

    ![](./images/step1.7-stackcreated.png " ")

## Step 2: Terraform Plan (OPTIONAL)

When using Resource Manager to deploy an environment, execute a terraform **Plan** to verify the configuration. This is an optional step in this lab.

1.  [OPTIONAL] Click **Terraform Actions** -> **Plan** to validate your configuration. Click **Plan**. This takes about a minute, please be patient.

    ![](./images/terraformactions.png " ")

    ![](./images/step2.1-terraformclickplan.png " ")

    ![](./images/planjob.png " ")

    ![](./images/planjob1.png " ")

## Step 3: Terraform Apply

When using Resource Manager to deploy an environment, execute a terraform **Plan** and **Apply**. Let's do that now.

1.  At the top of your page, click on **Stack Details**.  Click the button, **Terraform Actions** -> **Apply**. Click **Apply**. This will create your instance and install Oracle 19c. This takes about a minute, please be patient.

    ![](./images/applyjob1.png " ")

    ![](./images/step3.1-terraformclickapply.png " ")

    ![](./images/applyjob2.png " ")

    ![](./images/step3.1-applyjob3.png " ")

2.  Once this job succeeds, you will get an apply complete notification from Terraform.  The public IPs will be list in the end of the log. Examine it closely, 1 resource has been added. Congratulations, your environment is created! Time to login to your instance to finish the configuration.

    ![](./images/applycomplete.png " ")

## Step 4: Connect to your Instance

Choose the environment where you created your ssh-key in the previous lab (Generate SSH Keys).

*NOTE 1:  If you are using your laptop to connect, you cannot connect while on VPN or in the Oracle office on clear-corporate (choose clear-internet). This does not apply to the Oracle Cloud Shell.*

*NOTE 2: The ssh-daemon may be disabled for the first 5 minutes or so while the instance is processing.  If you are unable to connect and certain you have a valid key, wait a few minutes and try again.*

### Oracle Cloud Shell

1.  To re-start the Oracle Cloud shell, go to your Cloud console and click the cloud shell icon to the right of the region. *Note: Make sure you are in the region you were assigned.*

    ![](./images/cloudshell.png " ")

2.  Go to **Compute** -> **Instances** and select the instance you created (make sure you choose the correct compartment).

    ![](./images/step4.1.2-computeinstance.png " ")

3.  On your instance's homepage, copy the Public IP addresss for your instance to a notepad.

    ![](./images/step4.1.3-instancehomepage.png " ")

4.  Enter the command below and update it with your cloud shell key name and your instance's public IP addess to login to your instance.

    ````
    ssh -i ~/.ssh/<sshkeyname> opc@<Your Compute Instance Public IP Address>
    ````

5.  When prompted, answer **yes** to continue connecting.

    ![](./images/step4.1.5-instancelogin.png " ")

6.  Continue to Step 5 on the left hand menu.

### MAC or Windows CYGWIN Emulator

1.  Go to **Compute** -> **Instances** and select the instance you created (make sure you choose the correct compartment).

2.  On the instance homepage, find the Public IP addresss for your instance.

3.  Open up a terminal (MAC) or cygwin emulator as the opc user.  Enter yes when prompted.

    ````
    ssh -i ~/.ssh/optionskey opc@<Your Compute Instance Public IP Address>
    ````

    ![](./images/cloudshellssh.png " ")

    ![](./images/cloudshelllogin.png " ")

4.  After successfully logging in, proceed to Step 5.

### Windows using Putty

1.  Open up putty and create a new connection.

    ````
    ssh -i ~/.ssh/optionskey opc@<Your Compute Instance Public IP Address>
    ````

    ![](./images/ssh-first-time.png " ")

2.  Enter a name for the session and click **Save**.

    ![](./images/putty-setup.png " ")

3.  Click **Connection** > **Data** in the left navigation pane and set the Auto-login username to root.

4.  Click **Connection** > **SSH** > **Auth** in the left navigation pane and configure the SSH private key to use by clicking Browse under Private key file for authentication.

5.  Navigate to the location where you saved your SSH private key file, select the file, and click Open.  NOTE:  You cannot connect while on VPN or in the Oracle office on clear-corporate (choose clear-internet).

    ![](./images/putty-auth.png " ")

6.  The file path for the SSH private key file now displays in the Private key file for authentication field.

7.  Click Session in the left navigation pane, then click Save in the Load, save or delete a stored session Step.

8.  Click Open to begin your session with the instance.

## Step 5: Verify the Database is Up

1.  From your connected session of choice **tail** the `buildsingle.log` or `buildsingle1.log` file. This file has the configures log of the database.

    ````
    <copy>
    tail -f /u01/ocidb/buildsingle*.log
    </copy>
    ````
    ![](./images/tailOfBuildDBInstanceLog.png " ")

2.  When you see the following message, the database setup is complete - **Completed successfully in XXXX seconds** (this may take up to 30 minutes). You can do the step 6 while wait the database ready .

    ![](./images/tailOfBuildDBInstanceLog_finished.png " ")

3.  Run the following command to verify the database with the SID **ORCL** is up and running.

    ````
    <copy>
    ps -ef | grep ORCL
    </copy>
    ````

    ![](./images/pseforcl.png " ")

4. Verify the listener is running:

    ````
    <copy>
    ps -ef | grep tns
    </copy>
    ````

    ![](./images/pseftns.png " ")

5.  Connect to the Database using SQL*Plus as the **oracle** user.

    ````
    <copy>
    sudo su - oracle
    sqlplus system/Ora_DB4U@localhost:1521/orclpdb
    exit
    </copy>
    ````

    ![](./images/sqlplus_login_orclpdb.png " ")

6.  To leave `sqlplus` you need to use the exit command. Copy and paste the text below into your terminal to exit sqlplus.

    ````
    <copy>
    exit
    </copy>
    ````

7.  Copy and paste the below command to exit from oracle user and become an **opc** user.

    ````
    <copy>
    exit
    </copy>
    ````

You now have a fully functional Oracle Database 19c instance **ORCL** running on Oracle Cloud Compute, the default pdb name is **orclpdb**.

## Step 6: Prepare the standby database

Using the same way to prepare the standby side database cloud service. This time please choose the 'dbcs-standby-num.zip' file in the Resource Manager. Input the number of environment you want to create and the password of the DB admin. You can choose another region and compartment for the standby database.

After complete, you have a standby database that SID is **ORCL**, same as the primary database, the default pdb name is also named **orclpdb**.


