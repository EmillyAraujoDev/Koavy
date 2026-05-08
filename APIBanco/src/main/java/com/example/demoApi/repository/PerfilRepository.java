package com.example.demoApi.repository;

import com.example.demoApi.model.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, Long> {
    // Busca um perfil pelo nome (ex: para verificar se 'ADMIN' existe)
    Optional<Perfil> findByNome(String nome);
}