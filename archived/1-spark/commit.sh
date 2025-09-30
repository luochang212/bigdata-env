docker exec -it spark-master bash

spark-submit --master spark://master:7077 /opt/share/simple_count.py