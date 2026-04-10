# Hướng dẫn quản lý User

## Tổng quan

Quản lý user SSH trên các server thông qua Ansible. Chỉ cần khai báo ở **2 nơi**:

| Nơi | Trả lời câu hỏi | File |
|-----|-----------------|------|
| **User là ai?** | Tên, SSH key, password | `vars/users.yml` + `vars/users_passwords.yml` |
| **User ở đâu, quyền gì?** | Host nào, sudo hay không | `inventory/product-X/hosts` |

## Cấu trúc file

```
vars/
  users.yml               # Danh sách toàn bộ user + SSH key (plain text)
  users_passwords.yml      # Password sudo (vault-encrypted)

inventory/product-X/
  hosts                    # Khai báo hosts + user assignment
```

---

## Inventory - khai báo ai ở đâu

```ini
[all]
host-1 ansible_host=10.0.0.1  sudoers=kienlt members=kienlt,hieupn,dev1
host-2 ansible_host=10.0.0.2  sudoers=kienlt members=kienlt,hieupn
host-3 ansible_host=10.0.0.3  sudoers=kienlt,dba members=kienlt,dba,dev1

[db]
host-3

[app]
host-1
host-2
```

Nhìn vào inventory là biết ngay:
- `host-1`: kienlt (sudo), hieupn, dev1 có access
- `host-2`: kienlt (sudo), hieupn có access
- `host-3`: kienlt + dba (sudo), dev1 có access

**Quy tắc:**
- `members` = danh sách tất cả user có quyền SSH vào host, cách nhau bởi dấu phẩy
- `sudoers` = user có quyền sudo, **bắt buộc phải nằm trong `members`**
- Host không khai báo `members` = không có user nào được manage

---

## Thêm user mới

### Bước 1: Thêm vào danh sách user

Sửa `vars/users.yml`:
```yaml
all_managed_users:
  # ... users hiện tại ...
  - name: new_guy
    ssh_key: "ssh-ed25519 AAAA... comment"
```

### Bước 2: Tạo password (nếu user cần sudo)

Tạo hash:
```bash
./scripts/generate-password.sh
```

Thêm vào file password:
```bash
ansible-vault edit vars/users_passwords.yml
# Thêm dòng:  new_guy: "$6$xxxx..."
```

### Bước 3: Thêm user vào inventory

Sửa `inventory/product-X/hosts`, thêm tên user vào host cần access:

```ini
# Trước
host-1 ansible_host=10.0.0.1  sudoers=kienlt members=kienlt,hieupn

# Sau - thêm new_guy (có sudo)
host-1 ansible_host=10.0.0.1  sudoers=kienlt,new_guy members=kienlt,hieupn,new_guy

# Sau - thêm new_guy (không sudo)
host-1 ansible_host=10.0.0.1  sudoers=kienlt members=kienlt,hieupn,new_guy
```

### Bước 4: Chạy

```bash
# Kiểm tra trước (dry-run)
ansible-playbook -i inventory/product-X/hosts playbooks/manage-users.yml --check --ask-vault-pass

# Chạy thật
ansible-playbook -i inventory/product-X/hosts playbooks/manage-users.yml --ask-vault-pass

# Chạy trên 1 host cụ thể
ansible-playbook -i inventory/product-X/hosts -l host-1 playbooks/manage-users.yml --ask-vault-pass
```

---

## Xóa user khỏi host

1. Bỏ tên user ra khỏi `members` (và `sudoers` nếu có) trong inventory
2. Chạy playbook `manage-users.yml`

> **Lưu ý:** Playbook `manage-users.yml` chỉ quản lý user được khai báo. Nó **không tự động xóa** user khỏi server. Cần chạy playbook riêng để xóa.

## Xóa user vĩnh viễn

1. Bỏ tên user ra khỏi tất cả inventory files
2. Xóa user khỏi `all_managed_users` trong `vars/users.yml`
3. Thêm vào `removed_users`:
   ```yaml
   removed_users:
     - old_guy
   ```
4. Chạy playbook **delete** riêng:
   ```bash
   # Kiểm tra trước
   ansible-playbook -i inventory/product-X/hosts playbooks/delete-users.yml --check

   # Xóa thật
   ansible-playbook -i inventory/product-X/hosts playbooks/delete-users.yml
   ```
5. Sau khi xóa xong, bỏ user khỏi `removed_users` để giữ file sạch

---

## Vault guide - Quản lý password

### Tạo password hash
```bash
./scripts/generate-password.sh
```

### Thêm/sửa password
```bash
# Lần đầu (file chưa encrypt)
ansible-vault encrypt vars/users_passwords.yml

# Sửa password (decrypt -> edit -> re-encrypt tự động)
ansible-vault edit vars/users_passwords.yml
```

Nội dung file:
```yaml
user_passwords:
  kienlt: "$6$xxxx$yyyy..."
  hieupn: "$6$xxxx$zzzz..."
```

### Chạy playbook với vault
```bash
# Nhập vault password mỗi lần
ansible-playbook ... --ask-vault-pass

# Dùng password file (khỏi nhập)
ansible-playbook ... --vault-password-file ~/.vault_pass
```

---

## Lỗi thường gặp

| Lỗi | Nguyên nhân | Cách fix |
|-----|------------|----------|
| `User 'xxx' is in sudoers but not in members` | Quên thêm user vào `members` | Thêm tên user vào `members=...,xxx` trong inventory |
| `User 'xxx' not found in vars/users.yml` | Chưa thêm vào master list | Thêm user vào `all_managed_users` trong `vars/users.yml` |
| `all_managed_users is empty` | File users.yml rỗng | Kiểm tra `vars/users.yml` |
| User không sudo được | Chưa có password | Thêm password vào `vars/users_passwords.yml` |
| User không sudo được | Không nằm trong `sudoers` | Thêm vào `sudoers=...,xxx` trong inventory |
