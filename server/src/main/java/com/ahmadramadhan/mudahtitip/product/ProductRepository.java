package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
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
