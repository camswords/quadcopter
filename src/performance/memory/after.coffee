
memoryUsedAfter = process.memory().usage

console.log "memory used: #{memoryUsedAfter - memoryUsedBefore}"
