# SSH KEY FOR EC2

### Step 1: Change the directory.

```
cd ssh_key
```

### Step 2: Create private and public key by using ssh-keygen.
#### Note: The name of the file should be `three_tier`

```
ssh-keygen -f three_tier
```

### Step 3: Change the access permission for `three_tier` private key.

```
sudo chmod 400 three_tier
```

