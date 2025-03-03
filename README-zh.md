### 使用说明

**README:** [中文](./README-zh.md) | [English](./README.md)

本项目用于上传 `rootfs` 和 `Image` 到 GitHub Releases。

---

#### 操作步骤：  
1. 将更新后的 `rootfs1.ext4` 和 `Image` 文件放置于项目目录  
2. 执行 `./uploadrootfs.sh` 自动上传流程：  
   - 修改脚本中的 `TAG_NAME` 和 `RELEASE_NAME`  
   - 确保 hvisor 项目中的 `download_all.sh` 使用相同的 `RELEASE_NAME`  
   - 建议覆盖原有 Release 文件以保证 PR 合并前的 CI 流程正常  

---

#### 需要重新上传的场景：  
- `hvisor-tool` 工具链变更（导致内核模块输出变化）  
- `Image` 版本更新  
- `linux.json` 或 `virtio_cfg.json` 配置文件修改  
- `test` 目录文件更新  