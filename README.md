# Kubernetes
Script para crear clúster de Kubernetes de manera automatizada.
Una vez se genera el token en el Master, se copia el "join" en tantos workers como se precisen. \
Finalmente, verificamos con: \
  kubectl get nodes -o wide
