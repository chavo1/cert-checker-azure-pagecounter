## Infrastructure Automation Setup
### Problem Statement:
This infrastructure automation challenge is designed to assess your ability to provision and manage cloud-based infrastructure using Infrastructure-as-Code (IaC) 
principles. 
You will create a public Git repository and set up a basic web application stack on a chosen Cloud Service Provider (e.g., AWS, Azure) using IaC tools like Terraform and Docker. 
The stack should include a load balancer, web server, and a database running on separate instances or services.

#### Script Requirements:

1. Create a public Git repository on a platform of your choice (e.g., GitHub, GitLab, Bitbucket).
2. Choose a Cloud Service Provider and Register an Account:
   * Select a free Cloud Service Provider (e.g., AWS, Azure, Google Cloud).
3. Automate Provisioning of the Application Stack:

   * Use Infrastructure-as-Code (IaC) tools such as Terraform, Docker, AWS CloudFormation, or Azure Resource Manager to automate the provisioning of the following components:
      * A load balancer.
      * Web server instances or containers (e.g., AWS EC2, Azure VMs, or AWS ECS).
      * A database of your choice (e.g., MySQL, PostgreSQL, or a managed service like AWS RDS or Azure Database).
   * Ensure that each component runs separately on virtual machines, containers, or as a managed service.

4. Implement automation for service fail-over, such as auto-restart of failing services.
   * Develop a script or use appropriate cloud-native features to detect service failures and initiate fail-over procedures.
   * Ensure that the fail-over process is well-documented in your repository.

5. Commit your IaC code, configuration files, and scripts to the Git repository.
   * Create clear and comprehensive documentation in the repository, including a README with setup instructions, explanations of code structure, and details on how manage the infrastructure.

##### Presentation of Working Solution:

   * Prepare a live demo of your infrastructure automation solution. This should not be a presentation but a working demonstration of your provisioned environment.
   * Be ready to showcase how your solution handles fail-over scenarios.

### Instructions for the Candidate:

1. Choose a scripting language in which you are comfortable.
2. Create a script that fulfills the requirements outlined above.
3. Document any external libraries or tools used, and provide clear instructions on how to execute the script.
4. Be prepared to explain your code, including your choice of scripting language and any design decisions made during the interview.