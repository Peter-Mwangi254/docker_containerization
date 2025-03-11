# 1. Base Image
FROM python:3.12-slim  


# 4. Set Working Directory
WORKDIR /app

# 5. Copy Files to Container
COPY . .

# 6. Install Dependencies
RUN pip install -r requirements.txt


# 7. Define Exposed Ports
EXPOSE 8080  

# 8. Set Default Command to Run
CMD ["python", "manage.py", "runserver", "0.0.0.0:8080"]
