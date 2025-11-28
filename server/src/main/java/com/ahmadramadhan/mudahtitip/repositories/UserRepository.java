package com.ahmadramadhan.mudahtitip.repositories;

import org.springframework.data.repository.CrudRepository;

import com.ahmadramadhan.mudahtitip.entities.User;

public interface UserRepository extends CrudRepository<User, Integer> {

}
