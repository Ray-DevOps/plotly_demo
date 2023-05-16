FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ..

EXPOSE 5000

CMD ["python", "./userapi.py", "-m" , "flask", "run", "--host=0.0.0.0", "--port=5000"]
