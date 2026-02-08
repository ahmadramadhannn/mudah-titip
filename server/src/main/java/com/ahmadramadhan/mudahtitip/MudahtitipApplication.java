package com.ahmadramadhan.mudahtitip;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MudahtitipApplication {

	public static void main(String[] args) {
		SpringApplication.run(MudahtitipApplication.class, args);
	}

}
