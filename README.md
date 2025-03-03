### Usage Instructions

**README:** [中文](./README-zh.md) | [English](./README.md)

This project is used to upload `rootfs` and `Image` to GitHub Releases.

---

#### Steps:  
1. Place the updated `rootfs1.ext4` and `Image` files in the project directory.  
2. Run `./uploadrootfs.sh` to automate the upload process:  
   - Modify `TAG_NAME` and `RELEASE_NAME` in the script  
   - Ensure `download_all.sh` in hvisor references the same `RELEASE_NAME`  
   - Recommended to overwrite existing Release files for CI compatibility before PR merging  

---

#### Scenarios Requiring Re-upload:  
- Changes to `hvisor-tool` (kernel module outputs modified)  
- `Image` version updates  
- Modifications to `linux.json` or `virtio_cfg.json`  
- Updates to files in the `test` directory  