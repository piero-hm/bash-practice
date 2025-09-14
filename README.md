
# snapinfo

**snapinfo** — un *snapshot* (informe) del estado del sistema y guardarlo con timestamp. Útil para diagnósticos rápidos antes de una demo o examen.

## Características
- Genera un informe con kernel, CPU, memoria, disco, IPs, top de procesos y logs.
- Guardado automático en `~/.snapinfo` (o ruta que especifiques).
- Opciones: `--save`, `--short`, `--top N`, `--help`.

## Instalación rápida
1. Clona o descarga este repo.
2. Haz ejecutable el script:
```bash
chmod +x snapinfo.sh

```


## Ejemplo de salida

<details>
<summary>Ver ejemplo de salida</summary>

```
snapinfo - informe del sistema
Fecha: 2025-09-13 18:34:41
Host: host-ejemplo (usuario@host-ejemplo)
----------------------------------------

1) Kernel / OS
Linux kernel-version #1 SMP PREEMPT_DYNAMIC ... x86_64 GNU/Linux

2) CPU (lscpu)
Architecture:                            x86_64
CPU op-mode(s):                          32-bit, 64-bit
CPU(s):                                  8
Model name:                              EjemploCPU 1234

3) Memoria
              total        used        free      shared  buff/cache   available
Mem:           15Gi       3.2Gi       9.8Gi       120Mi       2.0Gi        11Gi

4) Uso de disco (df -h)
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   12G   36G  25% /
tmpfs           3.9G  1.2M  3.9G   1% /run

5) IPs (interfaces)
IPs: 192.0.2.1 127.0.0.1

6) Top 5 procesos por CPU
  PID %CPU %MEM COMMAND
 1234 12.3  1.2  proceso-ejemplo
 2345  3.4  0.8  otro-proceso

Fin del informe.
```

</details>
