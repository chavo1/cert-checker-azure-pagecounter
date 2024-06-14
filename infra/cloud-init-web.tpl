#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io

# Flask application code
write_files:
  - path: /home/azureuser/app.py
    content: |
      from flask import Flask
      import MySQLdb
      import os
      import time

      app = Flask(__name__)

      db_host = os.getenv("DB_HOST")
      db_user = os.getenv("DB_USER")
      db_password = os.getenv("DB_PASSWORD")
      db_name = os.getenv("DB_NAME")

      def get_db_connection():
          return MySQLdb.connect(host=db_host, user=db_user, passwd=db_password, db=db_name)

      @app.route("/")
      def index():
          retry_count = 0
          max_retries = 3
          while retry_count < max_retries:
              try:
                  conn = get_db_connection()
                  cursor = conn.cursor()
                  # Create table with an auto-incremented primary key
                  cursor.execute("CREATE TABLE IF NOT EXISTS visits (id INT AUTO_INCREMENT PRIMARY KEY, count INT)")
                  # Insert or update the count
                  cursor.execute("INSERT INTO visits (id, count) VALUES (1, 1) ON DUPLICATE KEY UPDATE count = count + 1")
                  cursor.execute("SELECT count FROM visits WHERE id=1")
                  visit_count = cursor.fetchone()[0]
                  conn.commit()
                  cursor.close()
                  conn.close()
                  return f'Welcome to {os.getenv("HOSTNAME")}, visit count: {visit_count} (served by {os.getenv("HOSTNAME")})'
              except MySQLdb.OperationalError as e:
                  if e.args[0] == 1205:
                      retry_count += 1
                      time.sleep(2 ** retry_count)
                  else:
                      raise
          return "Error: Lock wait timeout exceeded, please try again later."

      if __name__ == "__main__":
          app.run(host="0.0.0.0", port=80)

  - path: /home/azureuser/Dockerfile
    content: |
      # Use Python 3.8 slim base image
      FROM python:3.8-slim

      # Set working directory
      WORKDIR /app

      # Copy requirements file
      COPY requirements.txt /app/
      RUN apt-get update && apt-get install -y apt-utils gcc pkg-config libmariadb-dev-compat libmariadb-dev && \
          which pkg-config && \
          pkg-config --version

      # Install Python dependencies
      RUN pip install --no-cache-dir -r requirements.txt

      # Copy application code
      COPY app.py /app

      # Set the command to run the Flask application
      CMD ["python", "app.py"]

  - path: /home/azureuser/requirements.txt
    content: |
      # Flask web framework
      Flask==2.0.2
      # Werkzeug utility library
      Werkzeug==2.0.3
      # MySQL client library
      mysqlclient==2.2.4

# Commands to set up Docker, build and run the Flask application container
runcmd:
  - sudo systemctl start docker  # Start Docker service
  - sudo systemctl enable docker  # Enable Docker to start on boot
  - sudo usermod -aG docker azureuser  # Add azureuser to the docker group
  - db_ip="${db_ip}"  # Get the database IP address
  - echo $db_ip | sudo tee /home/azureuser/db_ip.txt  # Save the database IP address to a file
  - sudo docker build -t flask-app /home/azureuser/ 2>&1 | sudo tee /var/log/docker_build.log  # Build the Docker image
  - sudo docker run -d -p 80:80 -e DB_HOST=$(cat /home/azureuser/db_ip.txt) -e DB_USER=counteruser -e DB_PASSWORD=P@ssword123! -e DB_NAME=counterdb -e HOSTNAME=$(hostname) flask-app 2>&1 | sudo tee /var/log/docker_run.log  # Run the Docker container
