# ROV MOD MENU — iOS starter

โปรเจกต์ต้นแบบ SwiftUI สำหรับจัดเก็บและจัดการไฟล์บน iPhone

- `project.yml` ใช้ XcodeGen สร้าง Xcode project บน macOS
- `Sources/` มีซอร์สโค้ด SwiftUI

ข้อจำกัด: แอปนี้เป็นตัวจัดการไฟล์ส่วนตัว ไม่แก้ไขไฟล์เกม ROV ไม่ปลดล็อกสกิน และไม่ติดตั้งมอดเข้าเกม

การสร้าง IPA ที่ติดตั้งได้ต้อง Build บน macOS/Xcode และเซ็นแอปด้วยใบรับรองและ provisioning profile ที่ถูกต้องจาก Apple
