package com.ahmadramadhan.mudahtitip.product;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.consignor.GuestConsignor;
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

    // Guest consignor methods
    List<Product> findByGuestOwner(GuestConsignor guestOwner);

    List<Product> findByGuestOwnerIdAndIsActiveTrue(Long guestOwnerId);

    List<Product> findByGuestOwnerId(Long guestOwnerId);
}
