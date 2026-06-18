package com.example.demoApi.controller;

import com.example.demoApi.model.Usuario;
import com.example.demoApi.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Autowired
    private UsuarioRepository repository;

    @PostMapping("/cadastro")
    public ResponseEntity<?> cadastrar(@RequestBody Usuario usuario) {
        if (usuario.getNome() == null || usuario.getNome().isBlank()
                || usuario.getEmail() == null || usuario.getEmail().isBlank()
                || usuario.getSenha() == null || usuario.getSenha().isBlank()) {
            return ResponseEntity.badRequest().body("nome, email e senha sao obrigatorios");
        }

        if (repository.findByEmail(usuario.getEmail()).isPresent()) {
            return ResponseEntity.status(409).body("E-mail ja cadastrado");
        }

        usuario.setEmail(usuario.getEmail().trim().toLowerCase());
        usuario.setSenha(hashIfNeeded(usuario.getSenha()));
        if (usuario.getAtivo() == null) {
            usuario.setAtivo(true);
        }
        Usuario salvo = repository.save(usuario);
        return ResponseEntity.ok(salvo);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario login) {
        if (login.getEmail() == null || login.getSenha() == null) {
            return ResponseEntity.badRequest().body("Informe email e senha");
        }

        Optional<Usuario> userOpt = repository.findByEmail(login.getEmail().trim().toLowerCase());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body("E-mail ou senha incorretos");
        }

        Usuario user = userOpt.get();
        if (!Boolean.TRUE.equals(user.getAtivo()) || !passwordMatches(login.getSenha(), user.getSenha())) {
            return ResponseEntity.status(401).body("E-mail ou senha incorretos");
        }

        user.setUltimoLogin(LocalDateTime.now());
        repository.save(user);
        return ResponseEntity.ok(user);
    }

    @GetMapping
    public List<Usuario> listarTodos() {
        return repository.findAll();
    }

    @GetMapping("/{id:[0-9]+}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Usuario> atualizar(@PathVariable Long id, @RequestBody Usuario dados) {
        return repository.findById(id).map(usuario -> {
            usuario.setPerfilId(dados.getPerfilId());
            usuario.setNome(dados.getNome());
            if (dados.getEmail() != null) {
                usuario.setEmail(dados.getEmail().trim().toLowerCase());
            }
            if (dados.getSenha() != null && !dados.getSenha().isBlank()) {
                usuario.setSenha(hashIfNeeded(dados.getSenha()));
            }
            usuario.setIdade(dados.getIdade());
            usuario.setDataNascimento(dados.getDataNascimento());
            usuario.setSexo(dados.getSexo());
            usuario.setTelefone(dados.getTelefone());
            usuario.setTipoSanguineo(dados.getTipoSanguineo());
            usuario.setPeso(dados.getPeso());
            usuario.setAltura(dados.getAltura());
            usuario.setMarcapasso(dados.getMarcapasso());
            usuario.setObsMed(dados.getObsMed());
            usuario.setCep(dados.getCep());
            usuario.setAvatarUrl(dados.getAvatarUrl());
            usuario.setFcmToken(dados.getFcmToken());
            usuario.setAtivo(dados.getAtivo());
            return ResponseEntity.ok(repository.save(usuario));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    private String hashIfNeeded(String senha) {
        if (senha.startsWith("$2a$") || senha.startsWith("$2b$") || senha.startsWith("$2y$")) {
            return senha;
        }
        return passwordEncoder.encode(senha);
    }

    private boolean passwordMatches(String senhaAberta, String senhaSalva) {
        if (senhaSalva == null) {
            return false;
        }
        if (senhaSalva.startsWith("$2a$") || senhaSalva.startsWith("$2b$") || senhaSalva.startsWith("$2y$")) {
            return passwordEncoder.matches(senhaAberta, senhaSalva);
        }
        return senhaSalva.equals(senhaAberta);
    }
}
