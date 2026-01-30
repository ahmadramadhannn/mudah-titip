package com.ahmadramadhan.mudahtitip.shop;

import com.ahmadramadhan.mudahtitip.auth.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {

    Optional<Shop> findByOwner(User owner);

    Optional<Shop> findByOwnerId(Long ownerId);

    List<Shop> findByIsActiveTrue();

    boolean existsByOwner(User owner);
}
