package com.example.demoApi.repository;

import com.example.demoApi.model.Batimento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BatimentoRepository extends JpaRepository<Batimento, Long> {
    List<Batimento> findByUsuarioIdOrderByTimestampDesc(Long usuarioId);
}
