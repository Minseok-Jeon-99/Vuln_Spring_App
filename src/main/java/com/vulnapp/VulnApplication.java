package com.vulnapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class VulnApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        SpringApplication.run(VulnApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("  VulnSpringApp 실행 중");
        System.out.println("  http://localhost:8082/nas/main/main.do");
        System.out.println("  H2 Console: http://localhost:8082/nas/h2-console");
        System.out.println("========================================\n");
    }
}
