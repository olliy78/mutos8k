cat in.txt | tee o1 o2
cat o1
cat o2
cat in.txt | tee -a o1 > o3
cat o1
cat o3
cat in.txt | tee o1 > o3
cat o1
