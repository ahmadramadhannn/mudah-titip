package com.ahmadramadhan.mudahtitip.repositories;

import com.ahmadramadhan.mudahtitip.entities.Product;
import com.ahmadramadhan.mudahtitip.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByOwner(User owner);

    List<Product> findByOwnerId(Long ownerId);

    List<Product> findByOwnerIdAndIsActiveTrue(Long ownerId);

    List<Product> findByCategory(String category);

    List<Product> findByNameContainingIgnoreCase(String name);
}
