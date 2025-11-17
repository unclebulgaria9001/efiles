# Consolidate Person Aliases in Timeline
# Links people with their nicknames and aliases

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "CONSOLIDATE PERSON ALIASES" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`nThis will consolidate duplicate person names in the timeline:" -ForegroundColor Yellow
Write-Host "  - Link aliases to canonical names" -ForegroundColor White
Write-Host "  - Merge 'Epstein', 'Jeffrey', 'Jeffrey Epstein' → 'Jeffrey Epstein'" -ForegroundColor White
Write-Host "  - Merge 'Maxwell', 'Ghislaine' → 'Ghislaine Maxwell'" -ForegroundColor White
Write-Host "  - Merge 'Virginia Roberts', 'Giuffre' → 'Virginia Roberts Giuffre'" -ForegroundColor White

Write-Host "`nBenefits:" -ForegroundColor Cyan
Write-Host "  ✓ More accurate VIP timelines" -ForegroundColor Green
Write-Host "  ✓ Better event counts" -ForegroundColor Green
Write-Host "  ✓ Cleaner data" -ForegroundColor Green
Write-Host "  ✓ Easier analysis" -ForegroundColor Green

# Run consolidation script
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "RUNNING CONSOLIDATION" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

python scripts\consolidate_timeline_aliases.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Consolidation failed" -ForegroundColor Red
    exit 1
}

# Regenerate timelines
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "REGENERATE TIMELINES" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nDo you want to regenerate timelines with consolidated names? (Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "`nRegenerating unified timeline..." -ForegroundColor Yellow
    python scripts\create_unified_timeline.py
    
    Write-Host "`nRegenerating mini-timelines..." -ForegroundColor Yellow
    python scripts\create_mini_timelines.py
    
    Write-Host "`n" + ("=" * 80) -ForegroundColor Green
    Write-Host "TIMELINES REGENERATED!" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor Green
}

# Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "GIT OPERATIONS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nDo you want to commit the changes? (Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "`nAdding files..." -ForegroundColor Yellow
    git add unified_timeline/ mini_timelines/ scripts/person_aliases.py scripts/consolidate_timeline_aliases.py
    
    Write-Host "Committing..." -ForegroundColor Yellow
    git commit -m "Consolidate person aliases in timeline - link nicknames and variations"
    
    Write-Host "Pushing..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host "`n  Committed and pushed!" -ForegroundColor Green
}

Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "CONSOLIDATION COMPLETE!" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nSee: unified_timeline\ALIAS_CONSOLIDATION_REPORT.md" -ForegroundColor Cyan
