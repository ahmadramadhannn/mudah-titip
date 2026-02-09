package com.ahmadramadhan.mudahtitip.complaint;

import com.ahmadramadhan.mudahtitip.auth.User;
import com.ahmadramadhan.mudahtitip.auth.UserRole;
import com.ahmadramadhan.mudahtitip.complaint.dto.CreateComplaintRequest;
import com.ahmadramadhan.mudahtitip.complaint.dto.ResolveComplaintRequest;
import com.ahmadramadhan.mudahtitip.consignment.Consignment;
import com.ahmadramadhan.mudahtitip.consignment.ConsignmentRepository;
import com.ahmadramadhan.mudahtitip.notification.NotificationService;
import com.ahmadramadhan.mudahtitip.notification.NotificationType;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for managing product complaints between shop owners and consignors.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final ConsignmentRepository consignmentRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

    /**
     * Create a new complaint. Only shop owners can file complaints.
     */
    @Transactional
    public Complaint createComplaint(User reporter, CreateComplaintRequest request) {
        if (reporter.getRole() != UserRole.SHOP_OWNER) {
            throw new IllegalArgumentException("Hanya pemilik toko yang dapat mengajukan keluhan");
        }

        Consignment consignment = consignmentRepository.findById(request.getConsignmentId())
                .orElseThrow(() -> new IllegalArgumentException("Konsinyasi tidak ditemukan"));

        // Verify the shop owner owns the shop where this consignment is placed
        if (!consignment.getShop().getOwner().getId().equals(reporter.getId())) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke konsinyasi ini");
        }

        String mediaUrlsJson = null;
        if (request.getMediaUrls() != null && !request.getMediaUrls().isEmpty()) {
            try {
                mediaUrlsJson = objectMapper.writeValueAsString(request.getMediaUrls());
            } catch (JsonProcessingException e) {
                log.error("Failed to serialize media URLs", e);
            }
        }

        Complaint complaint = Complaint.builder()
                .consignment(consignment)
                .reporter(reporter)
                .category(request.getCategory())
                .description(request.getDescription())
                .mediaUrls(mediaUrlsJson)
                .status(ComplaintStatus.OPEN)
                .build();

        complaint = complaintRepository.save(complaint);
        log.info("Complaint created by {} for consignment {}", reporter.getEmail(), consignment.getId());

        // Notify the consignor (product owner)
        User consignor = consignment.getProduct().getOwner();
        notificationService.createNotification(
                consignor,
                NotificationType.COMPLAINT_RECEIVED,
                "Keluhan Produk Baru",
                String.format("%s melaporkan masalah pada %s: %s",
                        consignment.getShop().getName(),
                        consignment.getProduct().getName(),
                        request.getCategory().getDisplayName()),
                complaint.getId(),
                "COMPLAINT");

        return complaint;
    }

    /**
     * Get all complaints for a consignor's products.
     */
    public List<Complaint> getComplaintsForConsignor(Long consignorId) {
        return complaintRepository.findByConsignorIdOrderByCreatedAtDesc(consignorId);
    }

    /**
     * Get all complaints filed by a shop owner.
     */
    public List<Complaint> getComplaintsForShopOwner(Long shopOwnerId) {
        return complaintRepository.findByReporterIdOrderByCreatedAtDesc(shopOwnerId);
    }

    /**
     * Get a single complaint by ID with access check.
     */
    public Complaint getComplaint(Long complaintId, User user) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new IllegalArgumentException("Keluhan tidak ditemukan"));

        // Check access: reporter or consignor can view
        boolean isReporter = complaint.getReporter().getId().equals(user.getId());
        boolean isConsignor = complaint.getConsignment().getProduct().getOwner().getId().equals(user.getId());

        if (!isReporter && !isConsignor) {
            throw new IllegalArgumentException("Anda tidak memiliki akses ke keluhan ini");
        }

        return complaint;
    }

    /**
     * Resolve a complaint. Only the product consignor can resolve.
     */
    @Transactional
    public Complaint resolveComplaint(Long complaintId, User resolver, ResolveComplaintRequest request) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new IllegalArgumentException("Keluhan tidak ditemukan"));

        // Verify the resolver is the consignor (product owner)
        if (!complaint.getConsignment().getProduct().getOwner().getId().equals(resolver.getId())) {
            throw new IllegalArgumentException("Anda tidak memiliki akses untuk menyelesaikan keluhan ini");
        }

        if (complaint.getStatus() == ComplaintStatus.RESOLVED ||
                complaint.getStatus() == ComplaintStatus.REJECTED) {
            throw new IllegalArgumentException("Keluhan sudah diselesaikan");
        }

        complaint.setStatus(request.isAccepted() ? ComplaintStatus.RESOLVED : ComplaintStatus.REJECTED);
        complaint.setResolution(request.getResolution());
        complaint.setResolvedAt(LocalDateTime.now());
        complaint.setResolvedBy(resolver);

        complaint = complaintRepository.save(complaint);
        log.info("Complaint {} resolved by {}: {}", complaintId, resolver.getEmail(),
                request.isAccepted() ? "accepted" : "rejected");

        // Notify the reporter (shop owner)
        notificationService.createNotification(
                complaint.getReporter(),
                NotificationType.COMPLAINT_RESOLVED,
                "Keluhan Ditanggapi",
                String.format("Keluhan untuk %s telah %s oleh penitip",
                        complaint.getConsignment().getProduct().getName(),
                        request.isAccepted() ? "diterima" : "ditolak"),
                complaint.getId(),
                "COMPLAINT");

        return complaint;
    }

    /**
     * Count open complaints for a consignor.
     */
    public long countOpenComplaints(Long consignorId) {
        return complaintRepository.countOpenComplaintsByConsignorId(consignorId);
    }
}
